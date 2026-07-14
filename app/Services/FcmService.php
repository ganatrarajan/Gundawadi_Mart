<?php

namespace App\Services;

use App\Models\Notification;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class FcmService
{
    /**
     * Send a notification to a specific user and device.
     */
    public static function send($userType, $userId, $deviceToken, $title, $body)
    {
        // 1. Always log the notification locally in the database for app fetch API fallback
        Notification::create([
            'user_type' => $userType,
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'is_read' => false,
        ]);

        Log::info("Notification Sent locally to {$userType} (ID: {$userId}, Token: {$deviceToken}): [{$title}] - {$body}");

        // 2. Attempt FCM send if device token and FCM configurations exist
        if (empty($deviceToken)) {
            return false;
        }

        $credentialsPath = env('FIREBASE_CREDENTIALS');
        if (empty($credentialsPath) || !file_exists($credentialsPath)) {
            Log::debug("FCM sending skipped: FIREBASE_CREDENTIALS not configured or file not found.");
            return false;
        }

        try {
            // Read credentials
            $json = json_decode(file_get_contents($credentialsPath), true);
            $projectId = $json['project_id'];

            // Get access token (OAuth 2.0 flow for Firebase HTTP v1)
            $token = self::getGoogleAccessToken($json);
            if (!$token) {
                Log::error("Failed to generate Google OAuth token for FCM.");
                return false;
            }

            $response = Http::withToken($token)
                ->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", [
                    'message' => [
                        'token' => $deviceToken,
                        'notification' => [
                            'title' => $title,
                            'body' => $body,
                        ],
                        'data' => [
                            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                            'sound' => 'default',
                            'title' => (string) $title,
                            'body' => (string) $body,
                        ],
                    ],
                ]);

            if ($response->successful()) {
                Log::info("FCM Notification sent successfully to project {$projectId}");
                return true;
            } else {
                Log::error("FCM API failed: " . $response->body());
                return false;
            }
        } catch (\Exception $e) {
            Log::error("FCM Notification delivery error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Generate OAuth 2.0 Access Token using JWT.
     */
    private static function getGoogleAccessToken(array $json)
    {
        $privateKey = $json['private_key'];
        $clientEmail = $json['client_email'];

        $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
        $now = time();
        $payload = json_encode([
            'iss' => $clientEmail,
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'exp' => $now + 3600,
            'iat' => $now,
        ]);

        $base64UrlHeader = self::base64UrlEncode($header);
        $base64UrlPayload = self::base64UrlEncode($payload);

        $signature = '';
        if (!openssl_sign($base64UrlHeader . "." . $base64UrlPayload, $signature, $privateKey, OPENSSL_ALGO_SHA256)) {
            return null;
        }

        $base64UrlSignature = self::base64UrlEncode($signature);
        $jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;

        $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt,
        ]);

        if ($response->successful()) {
            return $response->json()['access_token'] ?? null;
        }

        return null;
    }

    private static function base64UrlEncode($data)
    {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
    }
}
