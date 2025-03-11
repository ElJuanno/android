<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
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

// Obtener datos enviados por POST
$data = json_decode(file_get_contents("php://input"), true);
$nombre = $data['nombre'] ?? '';
$telefono = $data['telefono'] ?? '';
$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

// Validar campos obligatorios (nombre, email y password)
if (empty($nombre) || empty($email) || empty($password)) {
    echo json_encode(["success" => false, "message" => "Faltan campos obligatorios"]);
    exit();
}

// Verificar si el email ya existe
$stmt = $conn->prepare("SELECT * FROM usuarios WHERE email = :email LIMIT 1");
$stmt->bindParam(':email', $email);
$stmt->execute();
$existingUser = $stmt->fetch(PDO::FETCH_ASSOC);

if ($existingUser) {
    echo json_encode(["success" => false, "message" => "El correo ya está registrado"]);
    exit();
}

// Hashear la contraseña
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Insertar nuevo usuario en la base de datos
$stmt = $conn->prepare("INSERT INTO usuarios (nombre, telefono, email, password) VALUES (:nombre, :telefono, :email, :password)");
$stmt->bindParam(':nombre', $nombre);
$stmt->bindParam(':telefono', $telefono);
$stmt->bindParam(':email', $email);
$stmt->bindParam(':password', $hashedPassword);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Registro exitoso"]);
} else {
    echo json_encode(["success" => false, "message" => "Error al registrar el usuario"]);
}
?>
