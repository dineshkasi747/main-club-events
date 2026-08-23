<?php
include 'e:/college/portal/backend/config/db.php';

// Clear tables
$pdo->exec("DELETE FROM clubs");
$pdo->exec("DELETE FROM events");
$pdo->exec("DELETE FROM registrations");
$pdo->exec("DELETE FROM historical_events WHERE clubId NOT IN (104, 105, 106, 107)");

// Insert clubs
$clubs = [
    [104, 'AIML Club', 'The official Artificial Intelligence and Machine Learning club of GVP. We organize Deep Learning workshops, LLM guest lectures, and competitive hackathons.', 7, 'Kalyan Ram', 350, '["Raghunadh","Kalyan Ram","Harsha","Sandeep","Sai Krishna"]'],
    [105, 'Data Science Club', 'The official Data Science club of GVPCE(A). We organize workshops on machine learning, competitive data sprints, and dashboard development challenges.', 1050, 'G. Surya Chaitanya', 320, '["A. Geethika","K.J.S.S. Manohar","Ch. Surya Teja","D.Y.N. Nandhitha","R. Naga Sai Nikhil"]'],
    [106, 'IEEE Computer Society', 'We empower people in technical advancement by delivering tools for individuals at all stages of their careers. As a professional chapter, we aid technology professionals stay active, involved, and engaged.', 1060, 'Mukalla Pallavi', 180, '["Sandra Rishitha M","B N V Hemanth","B Harika"]'],
    [107, 'Smart India Hackathon (SIH)', 'Official GVP Chapter for Smart India Hackathon 2026. Empowering student innovators to solve pressing real-world challenges posed by ministries and industries.', 1050, 'G. Surya Chaitanya', 450, '["Bongu Chandu","Kasi Sri Sai Dinesh","Mukalla Pallavi","Surya Chaitanya"]']
];

$stmtCl = $pdo->prepare("INSERT INTO clubs (id, name, description, presidentId, presidentName, membersCount, members) VALUES (?, ?, ?, ?, ?, ?, ?)");
foreach ($clubs as $c) {
    $stmtCl->execute($c);
}

// Insert events
$events = [
    [
        2026, 107, 'Registration for SIH 2026-Internal Hackathon',
        'Smart India Hackathon 2026 Internal Selection Hackathon. Submit your innovative problem statements and ideas for national shortlisting. Teams may submit up to 2 ideas.',
        'Main Auditorium & CSE Computer Labs, GVPCE(A)', 'Sep 25, 2026 @ 09:00 AM', 200.00, 500, 0, 1, 0, 0, 'active', 'assets/sih/posters/sih_poster.jpg'
    ],
    [
        2027, 104, 'Spheronix Technology Hackathon 2026',
        "An 8-Hour International Hackathon organized in collaboration with Spheronix Technology PVT LTD and Sisga Soft Technology.\n\n🏆 CASH PRIZES & REWARDS:\n• Total Cash Prize Pool: ₹2,00,000 to ₹5,00,000!\n• 1st Prize (Winner): Laptop & Top Cash Prize\n• 2nd Prize (Runner Up): Laptop & Cash Prize\n• 3rd Prize (2nd Runner Up): Laptop & Cash Prize\n(Note: As per company norms, the prize pool will be selected)\n\n⚡ FOCUS DOMAINS:\n• Bug Hunt\n• Full Stack Applications\n• Native Apps (Windows)\n• Quantum Computing\n• Health Tech / Digital Healthcare\n• AR / VR & 3D Design\n• Robotics\n\nOpen to all students (1st Year to Final Year)!",
        'Main Auditorium & Spheronix Innovation Lab, GVPCE(A)', 'Aug 28, 2026 @ 09:00 AM', 250.00, 1000, 0, 1, 0, 0, 'active', 'assets/sih/posters/spheronix_poster.png'
    ]
];

$stmtEv = $pdo->prepare("INSERT INTO events (id, clubId, title, description, venue, dateString, price, capacity, freeRegistration, paidRegistration, volunteerRegistration, volunteerLimit, status, imagePath) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
foreach ($events as $e) {
    $stmtEv->execute($e);
}

echo "Database successfully reseeded with clean clubs and events.\n";
