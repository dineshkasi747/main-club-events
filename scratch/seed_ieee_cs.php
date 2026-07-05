<?php
require 'portal/backend/config/db.php';

echo "Seeding IEEE Computer Society President...\n";

// 1. Seed IEEE CS President
$presidentStmt = $pdo->prepare("INSERT INTO users (id, email, password, role, name, clubId) VALUES (:id, :email, :password, 'president', :name, :clubId)
    ON DUPLICATE KEY UPDATE name = VALUES(name), email = VALUES(email)");
$presidentStmt->execute([
    'id' => 1060,
    'email' => 'ieee_cs@college.edu',
    'password' => password_hash('password', PASSWORD_DEFAULT),
    'name' => 'Mukalla Pallavi',
    'clubId' => 106
]);

echo "Seeding IEEE Computer Society Club...\n";

// 2. Seed IEEE CS Club
$clubStmt = $pdo->prepare("INSERT INTO clubs (id, name, description, presidentId, presidentName, membersCount, members) VALUES (:id, :name, :description, :presidentId, :presidentName, :membersCount, :members)
    ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), presidentName = VALUES(presidentName)");
$clubStmt->execute([
    'id' => 106,
    'name' => 'IEEE Computer Society',
    'description' => 'We empower people in technical advancement by delivering tools for individuals at all stages of their careers. As a professional chapter, we aid technology professionals stay active, involved, and engaged.',
    'presidentId' => 1060,
    'presidentName' => 'Mukalla Pallavi',
    'membersCount' => 180,
    'members' => json_encode(['Sandra Rishitha M', 'B N V Hemanth', 'B Harika'])
]);

// 3. Clear existing IEEE CS club events from the database to avoid duplicate key errors on rerun
$pdo->exec("DELETE FROM historical_events WHERE clubId = 106");
$pdo->exec("DELETE FROM events WHERE clubId = 106");

echo "Seeding IEEE Computer Society Upcoming Event...\n";

// 4. Seed Upcoming Event
$eventStmt = $pdo->prepare("INSERT INTO events (id, clubId, title, description, venue, dateString, price, capacity, freeRegistration, paidRegistration, volunteerRegistration, volunteerLimit, status, imagePath) VALUES (:id, :clubId, :title, :description, :venue, :dateString, :price, :capacity, :freeRegistration, :paidRegistration, :volunteerRegistration, :volunteerLimit, :status, :imagePath)");
$eventStmt->execute([
    'id' => 1006,
    'clubId' => 106,
    'title' => 'Quantum Computing Seminar',
    'description' => 'An introductory session on Quantum Computing, qubits, quantum gates, and future applications in cryptography and optimization.',
    'venue' => 'Seminar Hall 1',
    'dateString' => 'Nov 12, 2026 @ 10:00 AM',
    'price' => 0.00,
    'capacity' => 150,
    'freeRegistration' => 1,
    'paidRegistration' => 0,
    'volunteerRegistration' => 1,
    'volunteerLimit' => 10,
    'status' => 'active',
    'imagePath' => 'assets/ieee_cs/posters/clash_of_minds.jpg'
]);

echo "Seeding IEEE Computer Society Historical Events...\n";

// 5. Seed Historical Events
$histStmt = $pdo->prepare("INSERT INTO historical_events (id, clubId, academicYear, title, date, venue, description, volunteersCount, images) VALUES (:id, :clubId, :academicYear, :title, :date, :venue, :description, :volunteersCount, :images)");

$historicalEvents = [
    [
        'id' => 2601,
        'clubId' => 106,
        'academicYear' => '2024-25',
        'title' => 'Clash of Minds',
        'date' => 'Oct 10, 2024',
        'venue' => 'Main Seminar Hall',
        'description' => 'Debate Competition to test public speaking and critical thinking skills.',
        'volunteersCount' => 8,
        'images' => json_encode(['assets/ieee_cs/posters/clash_of_minds.jpg'])
    ],
    [
        'id' => 2602,
        'clubId' => 106,
        'academicYear' => '2023-24',
        'title' => 'Blockchain Workshop',
        'date' => 'Nov 15, 2023',
        'venue' => 'Lab 3, Main Block',
        'description' => 'Hands-on workshop on Blockchain technology and smart contracts.',
        'volunteersCount' => 12,
        'images' => json_encode(['assets/ieee_cs/posters/blockchain.jpg'])
    ],
    [
        'id' => 2603,
        'clubId' => 106,
        'academicYear' => '2023-24',
        'title' => 'Break the Code',
        'date' => 'Dec 05, 2023',
        'venue' => 'IBM Lab, CSE Block',
        'description' => 'Coding competition where participants solve riddles and write code to unlock challenges.',
        'volunteersCount' => 10,
        'images' => json_encode(['assets/ieee_cs/posters/break_the_code.jpeg'])
    ],
    [
        'id' => 2604,
        'clubId' => 106,
        'academicYear' => '2022-23',
        'title' => 'THE CodHER',
        'date' => 'Mar 08, 2022',
        'venue' => 'Lab 2, Main Block',
        'description' => 'A coding competition dedicated for female students to showcase their programming skills.',
        'volunteersCount' => 15,
        'images' => json_encode(['assets/ieee_cs/posters/codher.jpg'])
    ],
    [
        'id' => 2605,
        'clubId' => 106,
        'academicYear' => '2022-23',
        'title' => 'JAM (Just A Minute)',
        'date' => 'Apr 12, 2022',
        'venue' => 'Seminar Hall 2',
        'description' => 'An interactive speech competition where speakers talk on various technical topics for one minute.',
        'volunteersCount' => 5,
        'images' => json_encode(['assets/ieee_cs/posters/jam.jpeg'])
    ],
    [
        'id' => 2606,
        'clubId' => 106,
        'academicYear' => '2022-23',
        'title' => 'Brain Hacks',
        'date' => 'Sep 20, 2022',
        'venue' => 'Seminar Hall 1',
        'description' => 'Aptitude & Reasoning Series designed to boost students\' logical thinking and problem-solving skills.',
        'volunteersCount' => 8,
        'images' => json_encode(['assets/ieee_cs/posters/brain_hacks.jpeg'])
    ],
    [
        'id' => 2607,
        'clubId' => 106,
        'academicYear' => '2022-23',
        'title' => 'Machine Learning Workshop',
        'date' => 'Oct 25, 2022',
        'venue' => 'IBM Lab',
        'description' => 'A comprehensive workshop on machine learning models, algorithms, and training techniques.',
        'volunteersCount' => 10,
        'images' => json_encode(['assets/ieee_cs/posters/ml_workshop.jpeg'])
    ],
    [
        'id' => 2608,
        'clubId' => 106,
        'academicYear' => '2022-23',
        'title' => 'Get Ready For infytq',
        'date' => 'May 10, 2022',
        'venue' => 'IBM Lab, Main Block',
        'description' => 'Warm up your skills and logical parsing for the Infytq certification exam.',
        'volunteersCount' => 10,
        'images' => json_encode(['assets/ieee_cs/posters/get_ready_for_infytq.jpeg'])
    ],
    [
        'id' => 2609,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'Brain Teasers',
        'date' => 'Oct 12, 2021',
        'venue' => 'Seminar Hall 1',
        'description' => 'A fun-filled event containing riddles, logical tests, and cognitive problem puzzles.',
        'volunteersCount' => 8,
        'images' => json_encode(['assets/ieee_cs/posters/brain_teasers.jpeg'])
    ],
    [
        'id' => 2610,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'Crack the code',
        'date' => 'Nov 15, 2021',
        'venue' => 'Lab 2, CSE Block',
        'description' => 'Analyze code snippets to spot bugs, optimize complexity, and forecast results.',
        'volunteersCount' => 8,
        'images' => json_encode(['assets/ieee_cs/posters/crack_the_code.jpeg'])
    ],
    [
        'id' => 2611,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'Let\'s Talk Tech',
        'date' => 'Dec 05, 2021',
        'venue' => 'Main Seminar Hall',
        'description' => 'A technical speech competition presenting ideas on modern technology trends.',
        'volunteersCount' => 5,
        'images' => json_encode(['assets/ieee_cs/posters/lets_talk_tech.jpeg'])
    ],
    [
        'id' => 2612,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'Cyber Security & Pen Testing',
        'date' => 'Jan 10, 2022',
        'venue' => 'Main Seminar Hall',
        'description' => 'An intensive workshop detailing security vulnerabilities, white-hat scanning, and API auditing.',
        'volunteersCount' => 15,
        'images' => json_encode(['assets/ieee_cs/posters/cyber_security.jpg'])
    ],
    [
        'id' => 2613,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'Code Wars',
        'date' => 'Feb 18, 2022',
        'venue' => 'CSE Labs',
        'description' => 'A competitive coding challenge to build speed, accuracy, and robust algorithms.',
        'volunteersCount' => 12,
        'images' => json_encode(['assets/ieee_cs/posters/code_wars.jpg'])
    ],
    [
        'id' => 2614,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'Jobs in top MNCs',
        'date' => 'Mar 15, 2022',
        'venue' => 'Online Seminar',
        'description' => 'Guide on crack interviews and positioning resumes for top technology multinational firms.',
        'volunteersCount' => 10,
        'images' => json_encode(['assets/ieee_cs/posters/mnc_jobs.jpg'])
    ],
    [
        'id' => 2615,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'Byte Code Quiz',
        'date' => 'Apr 22, 2022',
        'venue' => 'Seminar Hall 2',
        'description' => 'Trivia competition evaluating technical facts, architectures, and programming history.',
        'volunteersCount' => 8,
        'images' => json_encode(['assets/ieee_cs/posters/byte_code.jpg'])
    ],
    [
        'id' => 2616,
        'clubId' => 106,
        'academicYear' => '2021-22',
        'title' => 'IEEE CS Chapter Inauguration',
        'date' => 'May 20, 2021',
        'venue' => 'Main Auditorium',
        'description' => 'Official launch event of the IEEE Computer Society Chapter at GVPCE(A) with guest addresses.',
        'volunteersCount' => 15,
        'images' => json_encode(['assets/ieee_cs/posters/cs_inaug.jpg'])
    ]
];

foreach ($historicalEvents as $hEvent) {
    $histStmt->execute($hEvent);
}

echo "IEEE Computer Society club and events seeded successfully!\n";
