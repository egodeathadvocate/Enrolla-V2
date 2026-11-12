<?php
declare(strict_types=1);

// Keep this file outside the public web root if DCISM allows it.
// Never commit a real database password to the repository.
$databaseHost = 'localhost';
$databasePort = '5432';
$databaseName = 's25100817_Enrolla';
$databaseUser = 's25100817_Enrolla';
$databasePassword = 'REPLACE_ON_SERVER_ONLY';

$dsn = "pgsql:host={$databaseHost};port={$databasePort};dbname={$databaseName}";

try {
    $pdo = new PDO($dsn, $databaseUser, $databasePassword, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $error) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    $safeMessage = preg_replace('/password[=:]\s*\S+/i', 'password=[redacted]', $error->getMessage());
    echo json_encode([
        'ok' => false,
        'error' => 'Database connection failed.',
        'sqlstate' => $error->getCode(),
        'detail' => $safeMessage,
    ]);
    error_log('Enrolla database connection failed: ' . $error->getMessage());
    exit;
}
