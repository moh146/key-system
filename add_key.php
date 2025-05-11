<?php
$file = __DIR__ . '/keys.txt';
$key = trim($_POST['key'] ?? '');
$expiry = trim($_POST['expiry'] ?? '');
if ($key === '' || $expiry === '') {
    http_response_code(400);
    echo 'Both key and expiry are required.';
    exit;
}
if (!preg_match('/^[A-Za-z0-9_-]+$/', $key)) {
    http_response_code(400);
    echo 'Invalid key format.';
    exit;
}
$date = DateTime::createFromFormat('Y-m-d', $expiry);
if (!$date) {
    http_response_code(400);
    echo 'Invalid date format.';
    exit;
}
$lines = file($file, FILE_IGNORE_NEW_LINES|FILE_SKIP_EMPTY_LINES);
foreach ($lines as $line) {
    list($k,) = explode('|', $line);
    if (strcasecmp($k, $key) === 0) {
        http_response_code(409);
        echo 'Key already exists.';
        exit;
    }
}
$entry = $key . '|' . $date->format('Y-m-d') . PHP_EOL;
if (file_put_contents($file, $entry, FILE_APPEND|LOCK_EX) === false) {
    http_response_code(500);
    echo 'Failed to write to key file.';
    exit;
}
echo 'OK';
?>