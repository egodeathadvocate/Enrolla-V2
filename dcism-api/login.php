<?php
declare(strict_types=1);
require __DIR__ . '/bootstrap.php';

$input = request_json();
$identifier = trim((string)($input['identifier'] ?? ''));
$password = (string)($input['password'] ?? '');
if ($identifier === '' || $password === '') respond(['ok' => false, 'error' => 'Email or Student ID and password are required.'], 422);

$query = $pdo->prepare(
    'select u.id, u.email, u.password_hash, p.student_id, p.username, p.full_name, p.role, p.is_demo, p.is_active
     from users u join profiles p on p.id = u.id
     where lower(u.email) = lower(:identifier)
        or p.student_id = :identifier
        or lower(coalesce(p.username, '''')) = lower(:identifier)
     limit 1'
);
$query->execute(['identifier' => $identifier]);
$user = $query->fetch();
if (!$user || !$user['is_active'] || !password_verify($password, $user['password_hash'])) {
    respond(['ok' => false, 'error' => 'Incorrect email, Student ID, or password.'], 401);
}

session_regenerate_id(true);
$_SESSION['user_id'] = $user['id'];
$_SESSION['role'] = $user['role'];

unset($user['password_hash'], $user['is_active']);
respond(['ok' => true, 'user' => $user]);
