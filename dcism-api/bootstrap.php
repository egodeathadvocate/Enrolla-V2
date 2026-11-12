<?php
declare(strict_types=1);

session_start([
    'cookie_httponly' => true,
    'cookie_secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'cookie_samesite' => 'Lax',
]);

header('Content-Type: application/json; charset=utf-8');

function request_json(): array {
    $input = json_decode(file_get_contents('php://input'), true);
    return is_array($input) ? $input : [];
}

function respond(array $payload, int $status = 200): never {
    http_response_code($status);
    echo json_encode($payload);
    exit;
}

function require_session(): array {
    if (empty($_SESSION['user_id'])) respond(['ok' => false, 'error' => 'Authentication required.'], 401);
    return $_SESSION;
}

require __DIR__ . '/db.php';
