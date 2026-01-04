<?php
require __DIR__ . '/config.php';

$data = read_json();
$user_id = (int)($data['user_id'] ?? 0);
$country_id = (int)($data['country_id'] ?? 0);

if ($user_id <= 0 || $country_id <= 0) {
    json_response(['error' => 'user_id and country_id required'], 400);
}

$pdo = db();

$stmt = $pdo->prepare('SELECT is_admin FROM users WHERE id = ?');
$stmt->execute([$user_id]);
$row = $stmt->fetch();
if (!$row || (int)$row['is_admin'] !== 1) {
    json_response(['error' => 'forbidden'], 403);
}

$stmt = $pdo->prepare('DELETE FROM countries WHERE id = ?');
$stmt->execute([$country_id]);
json_response(['ok' => true]);
