<?php
declare(strict_types=1);
require __DIR__ . '/bootstrap.php';

$session = require_session();
$isAdmin = in_array($session['role'], ['admin', 'super_admin'], true);
$programs = $pdo->query('select * from programs order by code')->fetchAll();
$courses = $pdo->query('select * from courses order by code')->fetchAll();
$settings = $pdo->query('select * from enrollment_settings order by id limit 1')->fetchAll();
$profiles = $isAdmin
    ? $pdo->query('select * from profiles order by student_id nulls last, full_name')->fetchAll()
    : $pdo->prepare('select * from profiles where id = :id');
if (!$isAdmin) {
    $profiles->execute(['id' => $session['user_id']]);
    $profiles = $profiles->fetchAll();
}
$enrollmentsQuery = $isAdmin
    ? $pdo->query('select e.*, c.code as subject_code from enrollments e join courses c on c.id = e.course_id order by e.date_submitted')
    : $pdo->prepare('select e.*, c.code as subject_code from enrollments e join courses c on c.id = e.course_id where e.student_id = :id order by e.date_submitted');
if (!$isAdmin) $enrollmentsQuery->execute(['id' => $session['user_id']]);
$enrollments = $enrollmentsQuery->fetchAll();
$requestsQuery = $isAdmin
    ? $pdo->query('select r.*, c.code as subject_code from special_requests r left join courses c on c.id = r.course_id order by r.date_submitted desc')
    : $pdo->prepare('select r.*, c.code as subject_code from special_requests r left join courses c on c.id = r.course_id where r.student_id = :id order by r.date_submitted desc');
if (!$isAdmin) $requestsQuery->execute(['id' => $session['user_id']]);
$requests = $requestsQuery->fetchAll();
$profileId = $session['user_id'];
$profileDataQuery = $pdo->prepare('select * from student_profile_data where profile_id = :id');
$profileDataQuery->execute(['id' => $profileId]);
$notificationsQuery = $pdo->prepare('select * from notifications where profile_id = :id order by created_at desc');
$notificationsQuery->execute(['id' => $profileId]);
$payload = [
    'programs' => $programs, 'courses' => $courses, 'settings' => $settings,
    'profiles' => $profiles, 'enrollments' => $enrollments, 'requests' => $requests,
    'profileData' => $profileDataQuery->fetch() ?: null, 'notifications' => $notificationsQuery->fetchAll(),
];
if ($isAdmin) $payload['auditLogs'] = $pdo->query('select * from audit_logs order by created_at desc')->fetchAll();
respond(['ok' => true, 'state' => $payload]);
