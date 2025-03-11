<?php
header("Content-Type: application/json");

// Datos de conexión
$host = "localhost";
$dbname = "diabetees";
$username = "Juano";
$password = "Arigatos4";

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    echo json_encode(["error" => "Conexión fallida: " . $e->getMessage()]);
    exit();
}

// Obtener datos enviados por POST (ejemplo: email y password)
$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

// Consulta para validar usuario (recuerda almacenar contraseñas de forma segura, ej. usando hash)
$stmt = $conn->prepare("SELECT * FROM usuarios WHERE email = :email LIMIT 1");
$stmt->bindParam(':email', $email);
$stmt->execute();
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    // Verificar la contraseña (suponiendo que está hasheada)
    if (password_verify($password, $user['password'])) {
        echo json_encode(["success" => true, "message" => "Login correcto", "user" => $user]);
    } else {
        echo json_encode(["success" => false, "message" => "Contraseña incorrecta"]);
    }
} else {
    echo json_encode(["success" => false, "message" => "Usuario no encontrado"]);
}
?>
