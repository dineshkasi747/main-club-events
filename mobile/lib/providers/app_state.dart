import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/club.dart';
import '../models/event.dart';
import '../models/registration.dart';

class AppState extends ChangeNotifier {
  // Automatically resolve 10.0.2.2 for Android emulator, localhost for others
  static String get baseUrl {
    return 'https://gvp-college-portal.loca.lt/college/portal/backend/api.php';
  }

  static final List<Club> _defaultClubs = [
    Club(
      id: 101,
      name: "Tech Brew",
      description: "The official coding club of the campus. We organize hackathons, dev bootcamps, and build awesome software solutions.",
      presidentName: "Karan Malhotra",
      membersCount: 512,
      members: const ["Aarav Mehta", "Rohan Gupta", "Priya Das", "Siddharth Roy", "Sneha Rao"],
    ),
    Club(
      id: 102,
      name: "Nritya & Raga",
      description: "Where music meets dance. The cultural hub for vocalists, instrumentalists, and dancers to perform and express.",
      presidentName: "Ananya Sen",
      membersCount: 430,
      members: const ["Vikram Seth", "Kabir Shah", "Aditi Iyer", "Ishita Sen", "Rhea Nair"],
    ),
    Club(
      id: 103,
      name: "FinEdge & Sports",
      description: "Dedicated to athletic excellence and physical fitness. Organizing league matches, athletic meets, and fitness programs.",
      presidentName: "Rahul Verma",
      membersCount: 298,
      members: const ["Amit Singh", "Arjun Kapoor", "Neha Sharma", "Dev Patel", "Pooja Reddy"],
    ),
    Club(
      id: 104,
      name: "AIML Club",
      description: "The official Artificial Intelligence and Machine Learning club of GVP. We organize Deep Learning workshops, LLM guest lectures, and competitive hackathons.",
      presidentName: "Kalyan Ram",
      membersCount: 350,
      members: const ["Raghunadh", "Kalyan Ram", "Harsha", "Sandeep", "Sai Krishna"],
    ),
    Club(
      id: 105,
      name: "Data Science Club",
      description: "The official Data Science club of GVPCE(A). We organize workshops on machine learning, competitive data sprints, and dashboard development challenges.",
      presidentName: "G. Surya Chaitanya",
      membersCount: 320,
      members: const ["A. Geethika", "K.J.S.S. Manohar", "Ch. Surya Teja", "D.Y.N. Nandhitha", "R. Naga Sai Nikhil"],
    ),
    Club(
      id: 106,
      name: "IEEE Computer Society",
      description: "We empower people in technical advancement by delivering tools for individuals at all stages of their careers. As a professional chapter, we aid technology professionals stay active, involved, and engaged.",
      presidentName: "Mukalla Pallavi",
      membersCount: 180,
      members: const ["Sandra Rishitha M", "B N V Hemanth", "B Harika"],
    ),
  ];

  static final List<Event> _defaultEvents = [
    Event(
      id: 1001,
      clubId: 101,
      title: "CodeSprint 5.0 Hackathon",
      description: "The annual flag-ship 24-hour build challenge. Form a team, design an innovative solution, and present it to top-industry leaders. Pizza and energy drinks are on us!",
      venue: "Main Block, Lab 3",
      dateString: "Aug 27, 2026 @ 09:00 AM",
      price: 150.0,
      capacity: 120,
      freeRegistration: false,
      paidRegistration: true,
      volunteerRegistration: true,
      volunteerLimit: 15,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=600&auto=format&fit=crop&q=80",
    ),
    Event(
      id: 1002,
      clubId: 102,
      title: "Raga - The Music Night",
      description: "An enchanting evening of acoustic performances, rock bands, and classical recitals. Join us under the stars to celebrate the spirit of rhythm and expression.",
      venue: "Open Air Theatre",
      dateString: "Sep 05, 2026 @ 06:00 PM",
      price: 0.0,
      capacity: 300,
      freeRegistration: true,
      paidRegistration: false,
      volunteerRegistration: true,
      volunteerLimit: 25,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&auto=format&fit=crop&q=80",
    ),
    Event(
      id: 1003,
      clubId: 103,
      title: "Campus Cricket League",
      description: "Dust off your bats and shoes! The inter-branch cricket league is back. Matches will be held in the main sports arena with live commentary.",
      venue: "College Ground A",
      dateString: "Oct 12, 2026 @ 08:00 AM",
      price: 80.0,
      capacity: 80,
      freeRegistration: false,
      paidRegistration: true,
      volunteerRegistration: false,
      volunteerLimit: 0,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=600&auto=format&fit=crop&q=80",
    ),
    Event(
      id: 1004,
      clubId: 104,
      title: "AI & Deep Learning Hackathon",
      description: "Deploy deep learning models onto real-world datasets in a 12-hour coding sprint. Prizes for the most accurate and creative neural networks!",
      venue: "IBM Lab, Main Block",
      dateString: "Nov 14, 2026 @ 09:00 AM",
      price: 100.0,
      capacity: 150,
      freeRegistration: false,
      paidRegistration: true,
      volunteerRegistration: false,
      volunteerLimit: 0,
      status: "active",
      imagePath: "https://images.unsplash.com/photo-1677442136019-21780efad99a?w=600&auto=format&fit=crop&q=80",
    ),
    Event(
      id: 1005,
      clubId: 105,
      title: "Squid-O-Quiz",
      description: "A thrilling data science quiz competition with rounds on statistics, probability, machine learning, and data interpretation.",
      venue: "Lab 5, CSE Block",
      dateString: "Nov 20, 2026 @ 10:00 AM",
      price: 0.0,
      capacity: 150,
      freeRegistration: true,
      paidRegistration: false,
      volunteerRegistration: true,
      volunteerLimit: 10,
      status: "active",
      imagePath: "assets/dsclub/posters/soq_poster.jpeg",
    ),
    Event(
      id: 1006,
      clubId: 106,
      title: "Quantum Computing Seminar",
      description: "An introductory session on Quantum Computing, qubits, quantum gates, and future applications in cryptography and optimization.",
      venue: "Seminar Hall 1",
      dateString: "Nov 12, 2026 @ 10:00 AM",
      price: 0.0,
      capacity: 150,
      freeRegistration: true,
      paidRegistration: false,
      volunteerRegistration: true,
      volunteerLimit: 10,
      status: "active",
      imagePath: "assets/ieee_cs/posters/clash_of_minds.jpg",
    ),
  ];

  static final List<HistoricalEvent> _defaultHistoricalEvents = [
    HistoricalEvent(
      id: 2001,
      clubId: 101,
      academicYear: "2023-24",
      title: "Web Dev Bootcamp 2023",
      date: "Oct 15, 2023",
      venue: "Seminar Hall 1",
      description: "A comprehensive hands-on boot camp covering HTML, CSS, JavaScript, and modern frameworks like React.",
      volunteersCount: 12,
      images: const [
        "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2002,
      clubId: 101,
      academicYear: "2024-25",
      title: "CodeSprint 4.0 Hackathon",
      date: "May 27, 2025",
      venue: "Main Block Lab",
      description: "Last year's edition of the famous 12-Hour Build Challenge focusing on Generative AI and web tools.",
      volunteersCount: 18,
      images: const [
        "https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2003,
      clubId: 101,
      academicYear: "2025-26",
      title: "Cybersecurity Workshop",
      date: "Jan 10, 2026",
      venue: "IT Lab 2",
      description: "A workshop focused on white-hat hacking, capture-the-flag (CTF) basics, and securing web APIs.",
      volunteersCount: 8,
      images: const [
        "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2101,
      clubId: 102,
      academicYear: "2023-24",
      title: "Unplugged Acoustic Night",
      date: "Nov 22, 2023",
      venue: "Library lawns",
      description: "Cozy, warm musical performance featuring acoustic guitars, violins, and raw vocals on a winter evening.",
      volunteersCount: 10,
      images: const [
        "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2102,
      clubId: 102,
      academicYear: "2024-25",
      title: "Tarang: Battle of the Bands",
      date: "Feb 14, 2025",
      venue: "Open Air Theatre",
      description: "Deafening drums, roaring guitars, and thousands in the crowd. The biggest rock competition on campus.",
      volunteersCount: 24,
      images: const [
        "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2103,
      clubId: 102,
      academicYear: "2025-26",
      title: "Classical Symphony Concert",
      date: "Mar 05, 2026",
      venue: "Auditorium 2",
      description: "An exhibition of Indian classical raagas and orchestra pieces by student instrument players.",
      volunteersCount: 15,
      images: const [
        "https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2201,
      clubId: 103,
      academicYear: "2023-24",
      title: "Inter-House Football Cup",
      date: "Dec 05, 2023",
      venue: "Main Arena Pitch",
      description: "An intense, high-energy football championship between departments showing incredible sportsmanship.",
      volunteersCount: 15,
      images: const [
        "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1517649763962-0c623066013b?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2202,
      clubId: 103,
      academicYear: "2024-25",
      title: "Annual Athletic Meet",
      date: "Mar 11, 2025",
      venue: "Athletic Track",
      description: "Events ranging from 100m dashes to relay runs and long jumps, highlighting speed and endurance.",
      volunteersCount: 35,
      images: const [
        "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2203,
      clubId: 103,
      academicYear: "2025-26",
      title: "Table Tennis Invitational",
      date: "Apr 18, 2026",
      venue: "Indoor Stadium",
      description: "A rapid-paced table tennis competition hosting players from multiple colleges.",
      volunteersCount: 6,
      images: const [
        "https://images.unsplash.com/photo-1534067783941-51c9c23eccfd?w=500&auto=format&fit=crop",
        "https://images.unsplash.com/photo-1511067007398-7e4b90cfa4bc?w=500&auto=format&fit=crop"
      ],
    ),
    HistoricalEvent(
      id: 2301,
      clubId: 104,
      academicYear: "2025-26",
      title: "Git & GitHub Workshop",
      date: "Sep 09, 2025",
      venue: "IBM Lab",
      description: "A hands-on version control and collaborative platform workshop designed exclusively for students to understand branching, pull requests, and open source.",
      volunteersCount: 15,
      images: const [
        "assets/aiclub/images/6.1.jpg",
        "assets/aiclub/images/6.2.jpg",
        "assets/aiclub/images/6.3.jpg"
      ],
    ),
    HistoricalEvent(
      id: 2302,
      clubId: 104,
      academicYear: "2025-26",
      title: "Tool Wave AI Session",
      date: "Sep 24, 2025",
      venue: "Main Auditorium",
      description: "An interactive session exploring generative AI tools for code completion, image synthesis, and layout design acceleration.",
      volunteersCount: 8,
      images: const [
        "assets/aiclub/images/7.1.jpg",
        "assets/aiclub/images/7.2.jpg",
        "assets/aiclub/images/7.3.jpg",
        "assets/aiclub/images/7.4.jpg"
      ],
    ),
    HistoricalEvent(
      id: 2303,
      clubId: 104,
      academicYear: "2024-25",
      title: "AI Club Inauguration",
      date: "Oct 05, 2024",
      venue: "Main Auditorium",
      description: "The AI Club at GVPCE(A) marked its revival with a grand inauguration on October 5th, 2024, attended by distinguished faculty including Dr. A. Syamsundar, Vice Principal, and other department heads. The event featured engaging activities like the Code Crackdown Quiz and Turing Test Challenge, where students tested their technical knowledge and AI understanding. The club's leadership, K. Anil Kumar (President) and N. Renu Sriya (Secretary) outlined their vision for fostering innovation and learning in AI, setting a strong foundation for future activities.",
      volunteersCount: 10,
      images: const [
        "assets/aiclub/images/1.1.png",
        "assets/aiclub/images/1.2.png",
        "assets/aiclub/images/1.3.png"
      ],
    ),
    HistoricalEvent(
      id: 2304,
      clubId: 104,
      academicYear: "2024-25",
      title: "AI and DL Workshop",
      date: "Dec 05, 2024",
      venue: "Online (Google Meet)",
      description: "The AI Club of GVPCE successfully organized a highly informative and interactive Deep Learning and Artificial Intelligence Session on 20th & 21st December 2024 through Google Meet. The session was delivered by Mr. Sandeep Vissapragada, an alumnus of our college currently pursuing M.Tech at IIT Bhilai. The two-day session provided a structured and in-depth exploration of key concepts in Deep Learning and AI. The first day began with an introduction to Artificial Intelligence, its evolution over the years, and its impact on multiple industries. Participants were guided through the fundamentals of neural networks, activation functions, and optimization techniques, giving them a strong conceptual foundation.",
      volunteersCount: 8,
      images: const [
        "assets/aiclub/images/3.1.1.jpg",
        "assets/aiclub/images/4.2.jpg",
        "assets/aiclub/images/4.3.jpg"
      ],
    ),
    HistoricalEvent(
      id: 2305,
      clubId: 104,
      academicYear: "2024-25",
      title: "Introduction to LLM",
      date: "Dec 09, 2024",
      venue: "Seminar Hall",
      description: "Guest lecture by Dr. Eduri Raja speech on Large Language Models (LLMs) highlighted their transformative role in modern Artificial Intelligence, emphasizing their importance in enhancing natural language understanding and generation. He discussed how neural networks form the backbone of LLMs, enabling them to process and learn complex patterns from vast amounts of text data. Dr. Raja also covered core concepts of Natural Language Processing (NLP), such as tokenization, attention mechanisms, and language modeling, illustrating how these techniques power applications ranging from machine translation to conversational AI. His insights underscored the growing impact of LLMs in various industries, shaping the future of human-computer interaction and data analysis.",
      volunteersCount: 12,
      images: const [
        "assets/aiclub/images/3.1.jpg",
        "assets/aiclub/images/3.2.jpg",
        "assets/aiclub/images/3.3.jpg"
      ],
    ),
    HistoricalEvent(
      id: 2306,
      clubId: 104,
      academicYear: "2024-25",
      title: "Python Session",
      date: "Dec 10, 2024",
      venue: "IBM Lab",
      description: "The Python workshop provided participants with a comprehensive introduction to Python programming. It covered key topics such as basic syntax, data types, control flow (if-else, loops), and functions. Additionally, the workshop explored more advanced concepts like object-oriented programming, handling libraries, and practical applications in data analysis and web development. The session included hands-on coding exercises, aimed at reinforcing the theoretical concepts through real-world examples. Whether for beginners or those with some programming experience, the workshop offered valuable insights into Python versatility and its potential in various domains.",
      volunteersCount: 15,
      images: const [
        "assets/aiclub/images/2.3.jpg",
        "assets/aiclub/images/2.2.jpg",
        "assets/aiclub/images/2.1.jpg"
      ],
    ),
    HistoricalEvent(
      id: 2307,
      clubId: 104,
      academicYear: "2024-25",
      title: "DSA Session",
      date: "Jan 04, 2025",
      venue: "IBM Lab",
      description: "The AI Club of GVPCE organized an enriching session titled “DSA Fundamentals: Learn, Code, Conquer” on 4th January 2025 at the IBM Lab. The event was designed to help students strengthen their understanding of Data Structures and Algorithms (DSA) and inspire them to build problem-solving skills essential for programming and competitive coding. The session was led by Raghunadh, Vice President of the AI Club, who delivered an insightful and interactive talk on the fundamentals of DSA. Complex concepts were explained in a simplified manner, enabling juniors and beginners to grasp the core principles with ease.",
      volunteersCount: 14,
      images: const [
        "assets/aiclub/images/5.1.png",
        "assets/aiclub/images/5.2.png",
        "assets/aiclub/images/5.3.png"
      ],
    ),
    HistoricalEvent(
      id: 2501,
      clubId: 105,
      academicYear: "2024-25",
      title: "AI Summit",
      date: "16 DEC 2024",
      venue: "Main Auditorium",
      description: "The AI Summit was a highlight of the year, offering an exceptional opportunity to explore artificial intelligence and its groundbreaking applications. Featuring expert speakers like Dr. P. Satya Jayadev, Mr. Santosh Nimmani, and Mr. Raghu Pulaparthi, the event covered diverse topics such as AI agents, machine learning, ethical AI, and its future in automation. Attendees engaged with real-world case studies, learning about AI's impact in sectors like healthcare, finance, and logistics. The summit provided a unique platform for students to interact with industry leaders and gain insights into the future of AI.",
      volunteersCount: 14,
      images: const ["assets/dsclub/posters/7.png"],
    ),
    HistoricalEvent(
      id: 2502,
      clubId: 105,
      academicYear: "2023-24",
      title: "AlgoZenith",
      date: "15 JAN 2023",
      venue: "Main Auditorium",
      description: "Mastering advanced algorithms and competitive programming. Join us to explore this domain and enhance your skills alongside fellow enthusiasts.",
      volunteersCount: 11,
      images: const ["assets/dsclub/posters/40.jpg"],
    ),
    HistoricalEvent(
      id: 2503,
      clubId: 105,
      academicYear: "2024-25",
      title: "Bug Busters",
      date: "15 FEB 2025",
      venue: "Main Auditorium",
      description: "A high-stakes debugging challenge from the EKATHRA tech fest. Participants raced to fix complex logic errors in a variety of coding languages.",
      volunteersCount: 10,
      images: const ["assets/dsclub/posters/DSlogo.jpg"],
    ),
    HistoricalEvent(
      id: 2504,
      clubId: 105,
      academicYear: "2024-25",
      title: "Code Quest",
      date: "25 NOV 2024",
      venue: "Main Auditorium",
      description: "Department of Computer Science & Engineering (Data Science), under the esteemed guidance of Dr.Y. Anuradha, Associate Head of B.Tech CSE (DS), organized a successful event, chaired by Prof. A. B. Koteswara Rao, Principal. The session began with a time limit of 1 hour and 15 minutes for the students to compete among themselves to write a program in the language of their choice to generate the Nth term of a given sequence or progression, like arithmetic or geometric series for 10 questions ranging from Easy, Medium, Hard and Expert. This session is an useful experience for students who want to participate in competitive Coding in future because this gives them an experience with a fun way to learn about The competitive coding contest is perfect for coders of all levels with cash prizes for the top 3 scorers.",
      volunteersCount: 10,
      images: const ["assets/dsclub/posters/6.jpg"],
    ),
    HistoricalEvent(
      id: 2601,
      clubId: 106,
      academicYear: "2024-25",
      title: "Clash of Minds",
      date: "Oct 10, 2024",
      venue: "Main Seminar Hall",
      description: "Debate Competition to test public speaking and critical thinking skills.",
      volunteersCount: 8,
      images: const ["assets/ieee_cs/posters/clash_of_minds.jpg"],
    ),
    HistoricalEvent(
      id: 2602,
      clubId: 106,
      academicYear: "2023-24",
      title: "Blockchain Workshop",
      date: "Nov 15, 2023",
      venue: "Lab 3, Main Block",
      description: "Hands-on workshop on Blockchain technology and smart contracts.",
      volunteersCount: 12,
      images: const ["assets/ieee_cs/posters/blockchain.jpg"],
    ),
    HistoricalEvent(
      id: 2603,
      clubId: 106,
      academicYear: "2023-24",
      title: "Break the Code",
      date: "Dec 05, 2023",
      venue: "IBM Lab, CSE Block",
      description: "Coding competition where participants solve riddles and write code to unlock challenges.",
      volunteersCount: 10,
      images: const ["assets/ieee_cs/posters/break_the_code.jpeg"],
    ),
    HistoricalEvent(
      id: 2604,
      clubId: 106,
      academicYear: "2022-23",
      title: "THE CodHER",
      date: "Mar 08, 2022",
      venue: "Lab 2, Main Block",
      description: "A coding competition dedicated for female students to showcase their programming skills.",
      volunteersCount: 15,
      images: const ["assets/ieee_cs/posters/codher.jpg"],
    ),
    HistoricalEvent(
      id: 2605,
      clubId: 106,
      academicYear: "2022-23",
      title: "JAM (Just A Minute)",
      date: "Apr 12, 2022",
      venue: "Seminar Hall 2",
      description: "An interactive speech competition where speakers talk on various technical topics for one minute.",
      volunteersCount: 5,
      images: const ["assets/ieee_cs/posters/jam.jpeg"],
    ),
    HistoricalEvent(
      id: 2606,
      clubId: 106,
      academicYear: "2022-23",
      title: "Brain Hacks",
      date: "Sep 20, 2022",
      venue: "Seminar Hall 1",
      description: "Aptitude & Reasoning Series designed to boost students' logical thinking and problem-solving skills.",
      volunteersCount: 8,
      images: const ["assets/ieee_cs/posters/brain_hacks.jpeg"],
    ),
    HistoricalEvent(
      id: 2607,
      clubId: 106,
      academicYear: "2022-23",
      title: "Machine Learning Workshop",
      date: "Oct 25, 2022",
      venue: "IBM Lab",
      description: "A comprehensive workshop on machine learning models, algorithms, and training techniques.",
      volunteersCount: 10,
      images: const ["assets/ieee_cs/posters/ml_workshop.jpeg"],
    ),
    HistoricalEvent(
      id: 2608,
      clubId: 106,
      academicYear: "2022-23",
      title: "Get Ready For infytq",
      date: "May 10, 2022",
      venue: "IBM Lab, Main Block",
      description: "Warm up your skills and logical parsing for the Infytq certification exam.",
      volunteersCount: 10,
      images: const ["assets/ieee_cs/posters/get_ready_for_infytq.jpeg"],
    ),
    HistoricalEvent(
      id: 2609,
      clubId: 106,
      academicYear: "2021-22",
      title: "Brain Teasers",
      date: "Oct 12, 2021",
      venue: "Seminar Hall 1",
      description: "A fun-filled event containing riddles, logical tests, and cognitive problem puzzles.",
      volunteersCount: 8,
      images: const ["assets/ieee_cs/posters/brain_teasers.jpeg"],
    ),
    HistoricalEvent(
      id: 2610,
      clubId: 106,
      academicYear: "2021-22",
      title: "Crack the code",
      date: "Nov 15, 2021",
      venue: "Lab 2, CSE Block",
      description: "Analyze code snippets to spot bugs, optimize complexity, and forecast results.",
      volunteersCount: 8,
      images: const ["assets/ieee_cs/posters/crack_the_code.jpeg"],
    ),
    HistoricalEvent(
      id: 2611,
      clubId: 106,
      academicYear: "2021-22",
      title: "Let's Talk Tech",
      date: "Dec 05, 2021",
      venue: "Main Seminar Hall",
      description: "A technical speech competition presenting ideas on modern technology trends.",
      volunteersCount: 5,
      images: const ["assets/ieee_cs/posters/lets_talk_tech.jpeg"],
    ),
    HistoricalEvent(
      id: 2612,
      clubId: 106,
      academicYear: "2021-22",
      title: "Cyber Security & Pen Testing",
      date: "Jan 10, 2022",
      venue: "Main Seminar Hall",
      description: "An intensive workshop detailing security vulnerabilities, white-hat scanning, and API auditing.",
      volunteersCount: 15,
      images: const ["assets/ieee_cs/posters/cyber_security.jpg"],
    ),
    HistoricalEvent(
      id: 2613,
      clubId: 106,
      academicYear: "2021-22",
      title: "Code Wars",
      date: "Feb 18, 2022",
      venue: "CSE Labs",
      description: "A competitive coding challenge to build speed, accuracy, and robust algorithms.",
      volunteersCount: 12,
      images: const ["assets/ieee_cs/posters/code_wars.jpg"],
    ),
    HistoricalEvent(
      id: 2614,
      clubId: 106,
      academicYear: "2021-22",
      title: "Jobs in top MNCs",
      date: "Mar 15, 2022",
      venue: "Online Seminar",
      description: "Guide on crack interviews and positioning resumes for top technology multinational firms.",
      volunteersCount: 10,
      images: const ["assets/ieee_cs/posters/mnc_jobs.jpg"],
    ),
    HistoricalEvent(
      id: 2615,
      clubId: 106,
      academicYear: "2021-22",
      title: "Byte Code Quiz",
      date: "Apr 22, 2022",
      venue: "Seminar Hall 2",
      description: "Trivia competition evaluating technical facts, architectures, and programming history.",
      volunteersCount: 8,
      images: const ["assets/ieee_cs/posters/byte_code.jpg"],
    ),
    HistoricalEvent(
      id: 2616,
      clubId: 106,
      academicYear: "2021-22",
      title: "IEEE CS Chapter Inauguration",
      date: "May 20, 2021",
      venue: "Main Auditorium",
      description: "Official launch event of the IEEE Computer Society Chapter at GVPCE(A) with guest addresses.",
      volunteersCount: 15,
      images: const ["assets/ieee_cs/posters/cs_inaug.jpg"],
    ),
  ];

  static final List<Registration> _defaultBookings = [
    Registration(
      id: 5001,
      userId: 5,
      userName: "Teja K.",
      userBranch: "Computer Science & Engineering",
      userRollNumber: "22CSE1084",
      userYearOfPassing: 2026,
      eventId: 1001,
      eventTitle: "CodeSprint 5.0 Hackathon",
      eventClubId: 101,
      eventPrice: 150.00,
      eventVenue: "Main Block, Lab 3",
      eventDate: "Aug 27, 2026 @ 09:00 AM",
      type: "participant",
      status: "pending",
      paymentMethod: "UPI (PhonePe)",
      paymentAmount: 150.00,
      transactionId: "TXN987654321",
      upiRefId: "TXN987654321",
      paymentScreenshot: "https://images.unsplash.com/photo-1554415707-6e8cfc93fe23?w=400",
      timestamp: "2026-06-26T12:00:00.000Z",
    )
  ];

  String? _token;
  Map<String, dynamic>? _user;
  List<Club> _clubs = List.from(_defaultClubs);
  List<Event> _events = List.from(_defaultEvents);
  List<Registration> _bookings = List.from(_defaultBookings);
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  AppState() {
    checkSavedSession();
  }

  Future<void> checkSavedSession() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.email != null) {
        final email = firebaseUser.email!;
        final displayName = firebaseUser.displayName ?? 'Student';
        
        _token = email;
        _user = {
          "id": 6,
          "name": displayName,
          "email": email,
          "role": "student",
          "branch": "Engineering",
          "rollNumber": "22GVP1234",
          "yearOfPassing": 2026
        };
        notifyListeners();

        try {
          final response = await http.post(
            Uri.parse('$baseUrl/auth/google-login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'name': displayName}),
          ).timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            _token = data['token'];
            _user = data['user'];
            notifyListeners();
            await fetchAllData();
            initFcm();
          }
        } catch (e) {
          print('Offline session restore, using local copy: $e');
          _clubs = List.from(_defaultClubs);
          _events = List.from(_defaultEvents);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Firebase Auth checkSavedSession error: $e');
    }
  }

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  List<Club> get clubs => _clubs;
  List<Event> get events => _events;
  List<Registration> get bookings => _bookings;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        fetchClubs(),
        fetchEvents(),
        fetchBookings(),
        fetchNotifications(),
      ]);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Mock login details directly for demo/offline functionality
      _token = "demo-jwt-token";
      _user = {
        "id": 5,
        "name": "Teja K.",
        "email": email.isNotEmpty ? email : "student@college.edu",
        "role": "student",
        "branch": "Computer Science & Engineering",
        "rollNumber": "22CSE1084",
        "yearOfPassing": 2026
      };
      
      // Also reset bookings list to default to keep it fresh
      _bookings = List.from(_defaultBookings);
      notifyListeners();

      // Attempt to hit the actual API if the server is alive, otherwise swallow error and proceed
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _token = data['token'];
          _user = data['user'];
          notifyListeners();
          await fetchAllData();
          initFcm();
        }
      } catch (e) {
        print('Backend offline or failed, using demo/mock mode: $e');
        _clubs = List.from(_defaultClubs);
        _events = List.from(_defaultEvents);
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Login error: $e');
      return true; // Return true anyway for offline/demo APK
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> googleLogin(String email, String displayName) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Mock login details directly for demo/offline functionality
      _token = email;
      _user = {
        "id": 6,
        "name": displayName,
        "email": email,
        "role": "student",
        "branch": "Engineering",
        "rollNumber": "22GVP1234",
        "yearOfPassing": 2026
      };
      
      _bookings = List.from(_defaultBookings);
      notifyListeners();

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/google-login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'name': displayName}),
        ).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _token = data['token'];
          _user = data['user'];
          notifyListeners();
          await fetchAllData();
          initFcm();
        }
      } catch (e) {
        print('Backend offline or failed, using demo/mock mode for Google: $e');
        _clubs = List.from(_defaultClubs);
        _events = List.from(_defaultEvents);
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Google Login error: $e');
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> demoLogin() async {
    return await login('student@gvpce.ac.in', 'password');
  }

  void logout() async {
    _token = null;
    _user = null;
    _bookings = [];
    _notifications = [];
    notifyListeners();
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<void> uploadFcmToken(String fcmToken) async {
    if (!isAuthenticated) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/users/fcm-token'),
        headers: _headers,
        body: jsonEncode({'token': fcmToken}),
      ).timeout(const Duration(seconds: 3));
      print('FCM Token uploaded successfully.');
    } catch (e) {
      print('uploadFcmToken error: $e');
    }
  }

  Future<void> initFcm() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        await uploadFcmToken(fcmToken);
      }
      messaging.onTokenRefresh.listen((newToken) {
        uploadFcmToken(newToken);
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received foreground push notification: ${message.notification?.title}");
        fetchNotifications();
      });
    } catch (e) {
      print("Firebase Messaging init skipped: $e");
    }
  }

  Future<void> fetchNotifications() async {
    if (!isAuthenticated) return;
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications'), headers: _headers).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _notifications = data.map((json) => Map<String, dynamic>.from(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch notifications error: $e');
    }
  }

  Future<void> fetchClubs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clubs')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _clubs = data.map((json) => Club.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch clubs error: $e');
      if (_clubs.isEmpty) {
        _clubs = List.from(_defaultClubs);
        notifyListeners();
      }
    }
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _events = data.map((json) => Event.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch events error: $e');
      if (_events.isEmpty) {
        _events = List.from(_defaultEvents);
        notifyListeners();
      }
    }
  }

  Future<void> fetchBookings() async {
    if (!isAuthenticated) return;
    try {
      final response = await http.get(Uri.parse('$baseUrl/registrations'), headers: _headers).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _bookings = data.map((json) => Registration.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Fetch bookings error: $e');
      if (_bookings.isEmpty) {
        _bookings = List.from(_defaultBookings);
        notifyListeners();
      }
    }
  }

  Future<Map<String, dynamic>?> fetchClubDetails(int clubId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clubs/$clubId')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        final List<dynamic> upcomingJson = data['upcomingEvents'] ?? [];
        final List<dynamic> pastJson = data['pastEvents'] ?? [];
        
        final upcoming = upcomingJson.map((j) => Event.fromJson(j)).toList();
        final past = pastJson.map((j) => HistoricalEvent.fromJson(j)).toList();

        return {
          'upcoming': upcoming,
          'past': past,
        };
      }
      return null;
    } catch (e) {
      print('Fetch club details error: $e');
      final upcoming = _events.where((ev) => ev.clubId == clubId).toList();
      final past = _defaultHistoricalEvents.where((ev) => ev.clubId == clubId).toList();
      return {
        'upcoming': upcoming,
        'past': past,
      };
    }
  }

  Future<bool> registerForEvent({
    required int eventId,
    required String type,
    String regMode = 'free',
    String paymentMethod = 'free',
    String transactionId = 'FREE_REG',
    String upiRefId = '',
    String paymentScreenshot = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/register'),
        headers: _headers,
        body: jsonEncode({
          'type': type,
          'regMode': regMode,
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
          'upiRefId': upiRefId,
          'paymentScreenshot': paymentScreenshot,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        await fetchBookings();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration failed: $e');
      final event = _events.firstWhere((ev) => ev.id == eventId, orElse: () => _events[0]);
      final newReg = Registration(
        id: DateTime.now().millisecondsSinceEpoch,
        userId: _user != null ? _user!['id'] : 5,
        userName: _user != null ? _user!['name'] : 'Teja K.',
        userBranch: _user != null ? _user!['branch'] : 'Computer Science & Engineering',
        userRollNumber: _user != null ? _user!['rollNumber'] : '22CSE1084',
        userYearOfPassing: _user != null ? _user!['yearOfPassing'] : 2026,
        eventId: event.id,
        eventTitle: event.title,
        eventClubId: event.clubId,
        eventPrice: regMode == 'paid' ? event.price : 0.0,
        eventVenue: event.venue,
        eventDate: event.dateString,
        type: type,
        status: regMode == 'paid' ? 'pending' : 'approved',
        paymentMethod: paymentMethod,
        paymentAmount: regMode == 'volunteer' ? 0.0 : (regMode == 'paid' ? event.price : 0.0),
        transactionId: transactionId,
        upiRefId: upiRefId,
        paymentScreenshot: paymentScreenshot,
        timestamp: DateTime.now().toIso8601String(),
      );
      _bookings.add(newReg);
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String venue,
    required String dateString,
    required double price,
    required int capacity,
    required bool freeRegistration,
    required bool paidRegistration,
    required bool volunteerRegistration,
    required int volunteerLimit,
    required int clubId,
    required String imagePath,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'venue': venue,
          'dateString': dateString,
          'price': price,
          'capacity': capacity,
          'freeRegistration': freeRegistration,
          'paidRegistration': paidRegistration,
          'volunteerRegistration': volunteerRegistration,
          'volunteerLimit': volunteerLimit,
          'clubId': clubId,
          'imagePath': imagePath,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 201) {
        final newEvent = Event.fromJson(jsonDecode(response.body));
        _events.insert(0, newEvent);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Create event failed, performing offline mock addition: $e');
      final newEvent = Event(
        id: DateTime.now().millisecondsSinceEpoch,
        clubId: clubId,
        title: title,
        description: description,
        venue: venue,
        dateString: dateString,
        price: price,
        capacity: capacity,
        freeRegistration: freeRegistration,
        paidRegistration: paidRegistration,
        volunteerRegistration: volunteerRegistration,
        volunteerLimit: volunteerLimit,
        status: 'active',
        imagePath: imagePath.isNotEmpty ? imagePath : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=600&auto=format&fit=crop&q=80',
      );
      _events.insert(0, newEvent);
      notifyListeners();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
