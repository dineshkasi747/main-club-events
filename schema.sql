CREATE DATABASE IF NOT EXISTS `college_clubs`;
USE `college_clubs`;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `email` VARCHAR(255) UNIQUE NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` VARCHAR(50) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `clubId` INT DEFAULT NULL,
  `branch` VARCHAR(255) DEFAULT NULL,
  `rollNumber` VARCHAR(100) DEFAULT NULL,
  `yearOfPassing` INT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `users` (`id`, `email`, `password`, `role`, `name`, `clubId`, `branch`, `rollNumber`, `yearOfPassing`) VALUES (1, 'admin@college.edu', 'admin', 'admin', 'Prof. R.K. Sharma', NULL, NULL, NULL, NULL);
INSERT INTO `users` (`id`, `email`, `password`, `role`, `name`, `clubId`, `branch`, `rollNumber`, `yearOfPassing`) VALUES (2, 'coding@college.edu', 'password', 'president', 'Karan Malhotra', 101, NULL, NULL, NULL);
INSERT INTO `users` (`id`, `email`, `password`, `role`, `name`, `clubId`, `branch`, `rollNumber`, `yearOfPassing`) VALUES (3, 'music@college.edu', 'password', 'president', 'Ananya Sen', 102, NULL, NULL, NULL);
INSERT INTO `users` (`id`, `email`, `password`, `role`, `name`, `clubId`, `branch`, `rollNumber`, `yearOfPassing`) VALUES (4, 'sports@college.edu', 'password', 'president', 'Rahul Verma', 103, NULL, NULL, NULL);
INSERT INTO `users` (`id`, `email`, `password`, `role`, `name`, `clubId`, `branch`, `rollNumber`, `yearOfPassing`) VALUES (5, 'student@college.edu', 'password', 'student', 'Teja K.', NULL, 'Computer Science & Engineering', '22CSE1084', 2026);
INSERT INTO `users` (`id`, `email`, `password`, `role`, `name`, `clubId`, `branch`, `rollNumber`, `yearOfPassing`) VALUES (6, 'ananya@college.edu', 'password', 'student', 'Ananya Roy', NULL, 'Electronics & Communication', '22ECE0942', 2026);

DROP TABLE IF EXISTS `clubs`;
CREATE TABLE `clubs` (
  `id` INT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `presidentId` INT NOT NULL,
  `presidentName` VARCHAR(255) NOT NULL,
  `membersCount` INT NOT NULL,
  `members` TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `clubs` (`id`, `name`, `description`, `presidentId`, `presidentName`, `membersCount`, `members`) VALUES (104, 'AIML Club', 'The official Artificial Intelligence and Machine Learning club of GVP. We organize Deep Learning workshops, LLM guest lectures, and competitive hackathons.', 7, 'Kalyan Ram', 350, '["Raghunadh","Kalyan Ram","Harsha","Sandeep","Sai Krishna"]');
INSERT INTO `clubs` (`id`, `name`, `description`, `presidentId`, `presidentName`, `membersCount`, `members`) VALUES (105, 'Data Science Club', 'The official Data Science club of GVPCE(A). We organize workshops on machine learning, competitive data sprints, and dashboard development challenges.', 1050, 'G. Surya Chaitanya', 320, '["A. Geethika","K.J.S.S. Manohar","Ch. Surya Teja","D.Y.N. Nandhitha","R. Naga Sai Nikhil"]');
INSERT INTO `clubs` (`id`, `name`, `description`, `presidentId`, `presidentName`, `membersCount`, `members`) VALUES (106, 'IEEE Computer Society', 'We empower people in technical advancement by delivering tools for individuals at all stages of their careers. As a professional chapter, we aid technology professionals stay active, involved, and engaged.', 1060, 'Mukalla Pallavi', 180, '["Sandra Rishitha M","B N V Hemanth","B Harika"]');
INSERT INTO `clubs` (`id`, `name`, `description`, `presidentId`, `presidentName`, `membersCount`, `members`) VALUES (107, 'Smart India Hackathon (SIH)', 'Official GVP Chapter for Smart India Hackathon 2026. Empowering student innovators to solve pressing real-world challenges posed by ministries and industries.', 1050, 'G. Surya Chaitanya', 450, '["Bongu Chandu","Kasi Sri Sai Dinesh","Mukalla Pallavi","Surya Chaitanya"]');


DROP TABLE IF EXISTS `events`;
CREATE TABLE `events` (
  `id` BIGINT PRIMARY KEY,
  `clubId` INT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `venue` VARCHAR(255) NOT NULL,
  `dateString` VARCHAR(255) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `capacity` INT NOT NULL,
  `freeRegistration` TINYINT(1) NOT NULL,
  `paidRegistration` TINYINT(1) NOT NULL,
  `volunteerRegistration` TINYINT(1) NOT NULL,
  `volunteerLimit` INT NOT NULL,
  `status` VARCHAR(50) DEFAULT 'active',
  `imagePath` VARCHAR(2083) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `events` (`id`, `clubId`, `title`, `description`, `venue`, `dateString`, `price`, `capacity`, `freeRegistration`, `paidRegistration`, `volunteerRegistration`, `volunteerLimit`, `status`, `imagePath`) VALUES (2026, 107, 'Registration for SIH 2026-Internal Hackathon', 'Smart India Hackathon 2026 Internal Selection Hackathon. Submit your innovative problem statements and ideas for national shortlisting. Teams may submit up to 2 ideas.', 'Main Auditorium & CSE Computer Labs, GVPCE(A)', 'Sep 25, 2026 @ 09:00 AM', 200.00, 500, 0, 1, 0, 0, 'active', 'assets/sih/posters/sih_poster.jpg');
INSERT INTO `events` (`id`, `clubId`, `title`, `description`, `venue`, `dateString`, `price`, `capacity`, `freeRegistration`, `paidRegistration`, `volunteerRegistration`, `volunteerLimit`, `status`, `imagePath`) VALUES (2027, 104, 'Spheronix Technology Hackathon 2026', 'An 8-Hour International Hackathon organized in collaboration with Spheronix Technology PVT LTD and Sisga Soft Technology.\n\n🏆 CASH PRIZES & REWARDS:\n• Total Cash Prize Pool: ₹2,00,000 to ₹5,00,000!\n• 1st Prize (Winner): Laptop & Top Cash Prize\n• 2nd Prize (Runner Up): Laptop & Cash Prize\n• 3rd Prize (2nd Runner Up): Laptop & Cash Prize\n(Note: As per company norms, the prize pool will be selected)\n\n⚡ FOCUS DOMAINS:\n• Bug Hunt\n• Full Stack Applications\n• Native Apps (Windows)\n• Quantum Computing\n• Health Tech / Digital Healthcare\n• AR / VR & 3D Design\n• Robotics\n\nOpen to all students (1st Year to Final Year)!', 'Main Auditorium & Spheronix Innovation Lab, GVPCE(A)', 'Aug 28, 2026 @ 09:00 AM', 250.00, 1000, 0, 1, 0, 0, 'active', 'assets/sih/posters/spheronix_poster.png');



DROP TABLE IF EXISTS `historical_events`;
CREATE TABLE `historical_events` (
  `id` INT PRIMARY KEY,
  `clubId` INT NOT NULL,
  `academicYear` VARCHAR(50) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `date` VARCHAR(255) NOT NULL,
  `venue` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `volunteersCount` INT NOT NULL,
  `images` TEXT NOT NULL,
  `report_data` LONGTEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2001, 101, '2023-24', 'Web Dev Bootcamp 2023', 'Oct 15, 2023', 'Seminar Hall 1', 'A comprehensive hands-on boot camp covering HTML, CSS, JavaScript, and modern frameworks like React.', 12, '["https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2002, 101, '2024-25', 'CodeSprint 4.0 Hackathon', 'May 27, 2025', 'Main Block Lab', 'Last year''s edition of the famous 12-Hour Build Challenge focusing on Generative AI and web tools.', 18, '["https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2003, 101, '2025-26', 'Cybersecurity Workshop', 'Jan 10, 2026', 'IT Lab 2', 'A workshop focused on white-hat hacking, capture-the-flag (CTF) basics, and securing web APIs.', 8, '["https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2101, 102, '2023-24', 'Unplugged Acoustic Night', 'Nov 22, 2023', 'Library lawns', 'Cozy, warm musical performance featuring acoustic guitars, violins, and raw vocals on a winter evening.', 10, '["https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2102, 102, '2024-25', 'Tarang: Battle of the Bands', 'Feb 14, 2025', 'Open Air Theatre', 'Deafening drums, roaring guitars, and thousands in the crowd. The biggest rock competition on campus.', 24, '["https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2103, 102, '2025-26', 'Classical Symphony Concert', 'Mar 05, 2026', 'Auditorium 2', 'An exhibition of Indian classical raagas and orchestra pieces by student instrument players.', 15, '["https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2201, 103, '2023-24', 'Inter-House Football Cup', 'Dec 05, 2023', 'Main Arena Pitch', 'An intense, high-energy football championship between departments showing incredible sportsmanship.', 15, '["https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1517649763962-0c623066013b?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2202, 103, '2024-25', 'Annual Athletic Meet', 'Mar 11, 2025', 'Athletic Track', 'Events ranging from 100m dashes to relay runs and long jumps, highlighting speed and endurance.', 35, '["https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2203, 103, '2025-26', 'Table Tennis Invitational', 'Apr 18, 2026', 'Indoor Stadium', 'A rapid-paced table tennis competition hosting players from multiple colleges.', 6, '["https://images.unsplash.com/photo-1534067783941-51c9c23eccfd?w=500&auto=format&fit=crop","https://images.unsplash.com/photo-1511067007398-7e4b90cfa4bc?w=500&auto=format&fit=crop"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2301, 104, '2025-26', 'Git & GitHub Workshop', 'Sep 09, 2025', 'IBM Lab', 'A hands-on version control and collaborative platform workshop designed exclusively for students to understand branching, pull requests, and open source.', 15, '["assets/aiclub/images/6.1.jpg","assets/aiclub/images/6.2.jpg","assets/aiclub/images/6.3.jpg"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2302, 104, '2025-26', 'Tool Wave AI Session', 'Sep 24, 2025', 'Main Auditorium', 'An interactive session exploring generative AI tools for code completion, image synthesis, and layout design acceleration.', 8, '["assets/aiclub/images/7.1.jpg","assets/aiclub/images/7.2.jpg","assets/aiclub/images/7.3.jpg","assets/aiclub/images/7.4.jpg"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2303, 104, '2024-25', 'AI Club Inauguration', 'Oct 05, 2024', 'Main Auditorium', 'The AI Club at GVPCE(A) marked its revival with a grand inauguration on October 5th, 2024, attended by distinguished faculty including Dr. A. Syamsundar, Vice Principal, and other department heads. The event featured engaging activities like the Code Crackdown Quiz and Turing Test Challenge, where students tested their technical knowledge and AI understanding. The club\'s leadership, K. Anil Kumar (President) and N. Renu Sriya (Secretary) outlined their vision for fostering innovation and learning in AI, setting a strong foundation for future activities.', 10, '["assets/aiclub/images/1.1.png","assets/aiclub/images/1.2.png","assets/aiclub/images/1.3.png"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2304, 104, '2024-25', 'AI and DL Workshop', 'Dec 05, 2024', 'Online (Google Meet)', 'The AI Club of GVPCE successfully organized a highly informative and interactive Deep Learning and Artificial Intelligence Session on 20th & 21st December 2024 through Google Meet. The session was delivered by Mr. Sandeep Vissapragada, an alumnus of our college currently pursuing M.Tech at IIT Bhilai. The two-day session provided a structured and in-depth exploration of key concepts in Deep Learning and AI. The first day began with an introduction to Artificial Intelligence, its evolution over the years, and its impact on multiple industries. Participants were guided through the fundamentals of neural networks, activation functions, and optimization techniques, giving them a strong conceptual foundation.', 8, '["assets/aiclub/images/3.1.1.jpg","assets/aiclub/images/4.2.jpg","assets/aiclub/images/4.3.jpg"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2305, 104, '2024-25', 'Introduction to LLM', 'Dec 09, 2024', 'Seminar Hall', 'Guest lecture by Dr. Eduri Raja speech on Large Language Models (LLMs) highlighted their transformative role in modern Artificial Intelligence, emphasizing their importance in enhancing natural language understanding and generation. He discussed how neural networks form the backbone of LLMs, enabling them to process and learn complex patterns from vast amounts of text data. Dr. Raja also covered core concepts of Natural Language Processing (NLP), such as tokenization, attention mechanisms, and language modeling, illustrating how these techniques power applications ranging from machine translation to conversational AI. His insights underscored the growing impact of LLMs in various industries, shaping the future of human-computer interaction and data analysis.', 12, '["assets/aiclub/images/3.1.jpg","assets/aiclub/images/3.2.jpg","assets/aiclub/images/3.3.jpg"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2306, 104, '2024-25', 'Python Session', 'Dec 10, 2024', 'IBM Lab', 'The Python workshop provided participants with a comprehensive introduction to Python programming. It covered key topics such as basic syntax, data types, control flow (if-else, loops), and functions. Additionally, the workshop explored more advanced concepts like object-oriented programming, handling libraries, and practical applications in data analysis and web development. The session included hands-on coding exercises, aimed at reinforcing the theoretical concepts through real-world examples. Whether for beginners or those with some programming experience, the workshop offered valuable insights into Python versatility and its potential in various domains.', 15, '["assets/aiclub/images/2.3.jpg","assets/aiclub/images/2.2.jpg","assets/aiclub/images/2.1.jpg"]');
INSERT INTO `historical_events` (`id`, `clubId`, `academicYear`, `title`, `date`, `venue`, `description`, `volunteersCount`, `images`) VALUES (2307, 104, '2024-25', 'DSA Session', 'Jan 04, 2025', 'IBM Lab', 'The AI Club of GVPCE organized an enriching session titled “DSA Fundamentals: Learn, Code, Conquer” on 4th January 2025 at the IBM Lab. The event was designed to help students strengthen their understanding of Data Structures and Algorithms (DSA) and inspire them to build problem-solving skills essential for programming and competitive coding. The session was led by Raghunadh, Vice President of the AI Club, who delivered an insightful and interactive talk on the fundamentals of DSA. Complex concepts were explained in a simplified manner, enabling juniors and beginners to grasp the core principles with ease.', 14, '["assets/aiclub/images/5.1.png","assets/aiclub/images/5.2.png","assets/aiclub/images/5.3.png"]');

DROP TABLE IF EXISTS `registrations`;
CREATE TABLE `registrations` (
  `id` BIGINT PRIMARY KEY,
  `userId` INT NOT NULL,
  `userName` VARCHAR(255) NOT NULL,
  `userBranch` VARCHAR(255) NOT NULL,
  `userRollNumber` VARCHAR(100) NOT NULL,
  `userYearOfPassing` INT NOT NULL,
  `eventId` BIGINT NOT NULL,
  `eventTitle` VARCHAR(255) NOT NULL,
  `eventClubId` INT NOT NULL,
  `eventPrice` DECIMAL(10,2) NOT NULL,
  `eventVenue` VARCHAR(255) NOT NULL,
  `eventDate` VARCHAR(255) NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `paymentMethod` VARCHAR(100) NOT NULL,
  `paymentAmount` DECIMAL(10,2) NOT NULL,
  `transactionId` VARCHAR(255) NOT NULL,
  `upiRefId` VARCHAR(255) DEFAULT '',
  `paymentScreenshot` VARCHAR(2083) DEFAULT '',
  `timestamp` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `registrations` (`id`, `userId`, `userName`, `userBranch`, `userRollNumber`, `userYearOfPassing`, `eventId`, `eventTitle`, `eventClubId`, `eventPrice`, `eventVenue`, `eventDate`, `type`, `status`, `paymentMethod`, `paymentAmount`, `transactionId`, `upiRefId`, `paymentScreenshot`, `timestamp`) VALUES (5001, 5, 'Teja K.', 'Computer Science & Engineering', '22CSE1084', 2026, 1001, 'CodeSprint 5.0 Hackathon', 101, 150, 'Main Block, Lab 3', 'Aug 27, 2026 @ 09:00 AM', 'participant', 'pending', 'UPI (PhonePe)', 150, 'TXN987654321', '', '', '2026-06-26T12:00:00.000Z');
INSERT INTO `registrations` (`id`, `userId`, `userName`, `userBranch`, `userRollNumber`, `userYearOfPassing`, `eventId`, `eventTitle`, `eventClubId`, `eventPrice`, `eventVenue`, `eventDate`, `type`, `status`, `paymentMethod`, `paymentAmount`, `transactionId`, `upiRefId`, `paymentScreenshot`, `timestamp`) VALUES (5002, 6, 'Ananya Roy', 'Electronics & Communication', '22ECE0942', 2026, 1001, 'CodeSprint 5.0 Hackathon', 101, 150, 'Main Block, Lab 3', 'Aug 27, 2026 @ 09:00 AM', 'volunteer', 'approved', 'free', 0, 'VOLUNTEER_REG', '', '', '2026-06-26T12:15:00.000Z');

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` BIGINT PRIMARY KEY,
  `clubId` INT NOT NULL,
  `clubName` VARCHAR(255) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `body` TEXT NOT NULL,
  `timestamp` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `notifications` (`id`, `clubId`, `clubName`, `title`, `body`, `timestamp`) VALUES (1782754526510, 102, 'Nritya & Raga', 'hello', 'hii', '2026-06-29T17:35:26.510Z');

DROP TABLE IF EXISTS `fcm_tokens`;
CREATE TABLE `fcm_tokens` (
  `userId` INT PRIMARY KEY,
  `token` TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

