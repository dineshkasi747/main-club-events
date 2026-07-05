<?php
require 'portal/backend/config/db.php';

// 1. Seed Data Science Club President
$presidentStmt = $pdo->prepare("INSERT INTO users (id, email, password, role, name, clubId) VALUES (:id, :email, :password, 'president', :name, :clubId)
    ON DUPLICATE KEY UPDATE name = VALUES(name), email = VALUES(email)");
$presidentStmt->execute([
    'id' => 1050,
    'email' => 'datascience@gvpce.ac.in',
    'password' => password_hash('password', PASSWORD_DEFAULT),
    'name' => 'G. Surya Chaitanya',
    'clubId' => 105
]);

// 2. Seed Data Science Club
$clubStmt = $pdo->prepare("INSERT INTO clubs (id, name, description, presidentId, presidentName, membersCount, members) VALUES (:id, :name, :description, :presidentId, :presidentName, :membersCount, :members)
    ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description), presidentName = VALUES(presidentName)");
$clubStmt->execute([
    'id' => 105,
    'name' => 'Data Science Club',
    'description' => 'The official Data Science club of GVPCE(A). We organize workshops on machine learning, competitive data sprints, and dashboard development challenges.',
    'presidentId' => 1050,
    'presidentName' => 'G. Surya Chaitanya',
    'membersCount' => 320,
    'members' => json_encode(['A. Geethika', 'K.J.S.S. Manohar', 'Ch. Surya Teja', 'D.Y.N. Nandhitha', 'R. Naga Sai Nikhil'])
]);

// 3. Clear existing Data Science club events from the database to avoid duplicate key errors on rerun
$pdo->exec("DELETE FROM historical_events WHERE clubId = 105");
$pdo->exec("DELETE FROM events WHERE clubId = 105");

// 4. Parse files and insert
$dir = 'e:/college/scratch/ds_repo/';
$files = glob($dir . '*.html');

// Exclude index, events, team, contact, videos, error, template etc.
$exclude = ['index.html', 'events.html', 'team.html', 'contact.html', 'videos.html', 'error.html', 'previous-events.html'];

$eventIdCounter = 2501;

foreach ($files as $file) {
    $basename = basename($file);
    if (in_array($basename, $exclude)) {
        continue;
    }

    echo "Parsing $basename...\n";
    $html = file_get_contents($file);

    // Title
    $title = '';
    if (preg_match('/<h1[^>]*>(.*?)<\/h1>/si', $html, $matches)) {
        $title = trim(strip_tags($matches[1]));
    }
    // Date
    $date = '';
    if (preg_match('/<p class="text-xl font-bold mt-1">(.*?)<\/p>/si', $html, $matches)) {
        $date = trim(strip_tags($matches[1]));
    } elseif (preg_match('/<span class="text-xs uppercase tracking-widest text-primary font-bold">(.*?)<\/span>/si', $html, $matches)) {
        // Fallback for events list date style
        $date = trim(strip_tags($matches[1]));
    }

    // Description/Overview
    $description = '';
    if (preg_match('/<section>\s*<h3[^>]*>Event Overview<\/h3>\s*<p[^>]*>(.*?)<\/p>/si', $html, $matches)) {
        $description = trim(strip_tags($matches[1]));
    }

    // If description is still empty, get text-text-muted
    if (empty($description)) {
        if (preg_match('/<p class="text-text-muted leading-relaxed[^"]*">(.*?)<\/p>/si', $html, $matches)) {
            $description = trim(strip_tags($matches[1]));
        } elseif (preg_match('/<p class="text-text-muted[^"]*">(.*?)<\/p>/si', $html, $matches)) {
            $description = trim(strip_tags($matches[1]));
        }
    }

    // Image
    $images = [];
    if (preg_match('/<div class="event-hero[^"]*">\s*<img src="assets\/images\/(.*?)"/si', $html, $matches)) {
        $imgName = $matches[1];
        // Handle posters case difference
        if ($imgName === 'poster.jpg') {
            $images[] = 'assets/dsclub/posters/Poster.jpg';
        } else {
            $images[] = 'assets/dsclub/posters/' . $imgName;
        }
    } else {
        // Find any image inside main
        if (preg_match('/<img src="assets\/images\/(.*?)"/si', $html, $matches)) {
            $imgName = $matches[1];
            if ($imgName === 'poster.jpg') {
                $images[] = 'assets/dsclub/posters/Poster.jpg';
            } else {
                $images[] = 'assets/dsclub/posters/' . $imgName;
            }
        }
    }

    // Specific galleries mapping
    if ($basename === 'squid-o-quiz.html') {
        $images = [
            "assets/dsclub/posters/soq_poster.jpeg",
            "assets/dsclub/posters/soq1.jpg",
            "assets/dsclub/posters/soq2.jpg",
            "assets/dsclub/posters/soq3.jpg",
            "assets/dsclub/posters/soq4.jpg",
            "assets/dsclub/posters/soq5.jpg"
        ];
    } elseif ($basename === 'data-structures.html') {
        $images = ["assets/dsclub/posters/Poster.jpg", "assets/dsclub/posters/1.jpg"];
    } elseif ($basename === 'git-github.html') {
        $images = ["assets/dsclub/posters/5.jpg", "assets/dsclub/posters/GET THE GIT.jpg"];
    }

    // Academic Year calculation
    $academicYear = '2024-25';
    if (!empty($date)) {
        if (stripos($date, '2025') !== false) {
            $academicYear = '2024-25';
        } elseif (stripos($date, '2024') !== false) {
            $academicYear = '2024-25';
        } elseif (stripos($date, '2023') !== false) {
            $academicYear = '2023-24';
        } elseif (stripos($date, '2022') !== false) {
            $academicYear = '2022-23';
        }
    }

    // Venue
    $venue = 'Main Auditorium';
    if (preg_match('/📌\s*<span[^>]*>Venue:\s*(.*?)<\/span>/si', $html, $matches)) {
        $venue = trim(strip_tags($matches[1]));
    }

    // Key Takeaways / Scope and Objectives
    $scope = 'To provide hands-on experience and deep understanding of the domain concepts.';
    if (preg_match('/<h4[^>]*>Key Takeaways<\/h4>\s*<ul[^>]*>(.*?)<\/ul>/si', $html, $matches)) {
        $list = $matches[1];
        preg_match_all('/<li>(.*?)<\/li>/si', $list, $liMatches);
        if (!empty($liMatches[1])) {
            $scope = implode(' ', array_map(function($val) {
                return trim(strip_tags(str_replace('📌', '', $val)));
            }, $liMatches[1]));
        }
    }

    // Report data structure
    $reportData = [
        'guestsOfHonour' => 'Dr. Y. Anuradha, Faculty Head',
        'conveners' => 'Dr. Y. Anuradha, Faculty Head',
        'coordinators' => 'Dr. Y. Anuradha',
        'scopeAndObjectives' => $scope,
        'outcomes' => 'Students gained deep insights and learned to apply knowledge in real-world scenarios.',
        'article' => $description,
        'reportPdf' => '',
        'studentConveners' => 'G. Surya Chaitanya',
        'studentTeams' => [
            'Vice President' => 'A. Geethika',
            'Treasurer' => 'K.J.S.S. Manohar',
            'Organizing Lead' => 'Ch. Surya Teja',
            'Web Lead' => 'R. Naga Sai Nikhil',
            'Technical Lead' => 'S. Charith'
        ]
    ];

    // Check if there is a drive link
    if (preg_match('/<a href="(https:\/\/drive\.google\.com[^"]*)"[^>]*>View Event Images/si', $html, $matches)) {
        $reportData['reportPdf'] = $matches[1];
    }

    // If it's squid-o-quiz, it is an UPCOMING event!
    // So we seed it into the `events` table as well!
    if ($basename === 'squid-o-quiz.html') {
        $upcomingStmt = $pdo->prepare("INSERT INTO events (id, clubId, title, description, venue, dateString, price, capacity, freeRegistration, paidRegistration, volunteerRegistration, volunteerLimit, status, imagePath) VALUES (:id, 105, :title, :description, :venue, :dateString, 0, 150, 1, 0, 0, 0, 'active', :imagePath)");
        $upcomingStmt->execute([
            'id' => 1005.0, // Unique upcoming ID
            'title' => $title,
            'description' => $description,
            'venue' => $venue,
            'dateString' => 'Feb 15, 2025 @ 10:00 AM',
            'imagePath' => 'assets/dsclub/posters/soq_poster.jpeg'
        ]);
        echo "Added upcoming event: $title\n";
    }

    // Insert into historical_events
    $stmt = $pdo->prepare("INSERT INTO historical_events (id, clubId, academicYear, title, date, venue, description, volunteersCount, images, report_data) VALUES (:id, 105, :academicYear, :title, :date, :venue, :description, :volunteers, :images, :reportData)");
    
    $stmt->execute([
        'id' => $eventIdCounter,
        'academicYear' => $academicYear,
        'title' => $title,
        'date' => $date ?: '15 FEB 2025',
        'venue' => $venue,
        'description' => $description,
        'volunteers' => rand(10, 15),
        'images' => json_encode($images),
        'reportData' => json_encode($reportData)
    ]);

    echo "Seeded historical event #$eventIdCounter: $title ($academicYear)\n";
    $eventIdCounter++;
}

echo "\nData Science Club and events seeded successfully!\n";
