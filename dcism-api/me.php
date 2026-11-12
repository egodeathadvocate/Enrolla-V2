<?php
declare(strict_types=1);
require __DIR__ . '/bootstrap.php';

$session = require_session();
$query = $pdo->prepare(
    'select u.id, u.email, p.student_id, p.username, p.full_name, p.role, p.is_demo, p.is_active
     from users u join profiles p on p.id = u.id where u.id = :id limit 1'
);
$query->execute(['id' => $session['user_id']]);
$user = $query->fetch();
if (!$user || !$user['is_active']) respond(['ok' => false, 'error' => 'Account is unavailable.'], 401);
respond(['ok' => true, 'user' => $user]);
