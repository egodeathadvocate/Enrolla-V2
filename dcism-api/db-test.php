<?php
declare(strict_types=1);

require __DIR__ . '/db.php';

try {
    $result = $pdo->query('select current_database() as database_name, current_user as database_user');
    $connection = $result->fetch();

    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'ok' => true,
        'message' => 'PHP can connect to PostgreSQL.',
        'database' => $connection['database_name'] ?? null,
        'user' => $connection['database_user'] ?? null,
    ]);
} catch (PDOException $error) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'ok' => false,
        'error' => 'Database test query failed.',
    ]);
    error_log('Enrolla database test failed: ' . $error->getMessage());
}

