-- Enrolla DCISM demo data.
-- Run this after dcism-schema.sql.
-- Demo password for both accounts: Demo@12345
-- Replace these demo records before production use.

insert into users (id, email, password_hash, email_verified)
values
  ('00000000-0000-0000-0000-000000000001', 'student.demo@enrolla.test', crypt('Demo@12345', gen_salt('bf')), true),
  ('00000000-0000-0000-0000-000000000002', 'admin.demo@enrolla.test', crypt('Demo@12345', gen_salt('bf')), true)
on conflict (id) do update set
  email = excluded.email,
  password_hash = excluded.password_hash,
  email_verified = excluded.email_verified,
  updated_at = now();

insert into programs (code, name, department, description, subject_codes)
values
  ('BSIT','Bachelor of Science in Information Technology','College of Computing & Information Sciences','Focuses on enterprise networking, software integration, database administration, web architecture, and human-computer interaction.','{"CS 201","IT 315","PE 201","IT 402","IT 208"}'),
  ('BSCS','Bachelor of Science in Computer Science','College of Computing & Information Sciences','Emphasizes algorithmic theory, object-oriented software engineering, discrete mathematics, formal logic, and systems programming.','{"IT 204","MATH 203","PHIL 102","CS 201"}'),
  ('BSBA','Bachelor of Science in Business Administration','College of Business & Management','Prepares students for corporate finance, accounting fundamentals, operations management, and strategic business communication.','{"ACC 101","GE 105"}'),
  ('BSIS','Bachelor of Science in Information Systems','College of Computing & Information Sciences','Bridges business processes and modern web information systems, enterprise resource planning, and systems analysis.','{"IT 299","IT 208","ACC 101"}')
on conflict (code) do update set
  name = excluded.name, department = excluded.department, description = excluded.description,
  subject_codes = excluded.subject_codes, updated_at = now();

insert into profiles (id, student_id, username, full_name, email, contact, program_code, year_level, enrollment_status, role, is_demo)
values
  ('00000000-0000-0000-0000-000000000001','12345678',null,'Jannica Lhei B. Andrade','student.demo@enrolla.test','+63 917 842 9104','BSIT','2nd Year','Enrolled','student',true),
  ('00000000-0000-0000-0000-000000000002',null,'admin.demo@enrolla.test','Demo Administrator','admin.demo@enrolla.test',null,null,null,'Enrolled','admin',true)
on conflict (id) do update set
  student_id = excluded.student_id, username = excluded.username, full_name = excluded.full_name,
  email = excluded.email, contact = excluded.contact, program_code = excluded.program_code,
  year_level = excluded.year_level, enrollment_status = excluded.enrollment_status,
  role = excluded.role, is_demo = excluded.is_demo, updated_at = now();

insert into courses (code,name,title,description,instructor,building,room,schedule_text,units,program_code,max_capacity,enrolled_count,status,course_type,days,start_hour,duration,color,prerequisite,topics) values
('CS 201','C Programming I','CS 201 - C Programming I','Fundamentals of C programming, pointers, loops, structures, and low-level memory management for hardware integration.','Dr. Alan','Computing Building','Lab 301','Mon/Wed 8:00 AM - 10:00 AM',4,'BSIT',35,28,'available','Core','{"Mon","Wed"}',8,2,'blue','CS 102 - Computer Programming 1','{"Pointers & Memory Allocation","Control Structures & Functions","Structs & File I/O","Bitwise Operations & Embedded C"}'),
('IT 315','Cisco Networking (NetAcad)','IT 315 - Cisco Networking (NetAcad)','Network topologies, Packet Tracer lab exercises, router and switch CLI configurations, subnetting, and physical layer setup.','Mr. Torres','Computing Building','Cisco Lab 202','Tue/Thu 10:00 AM - 11:30 AM',3,'BSIT',30,30,'available','Major','{"Tue","Thu"}',10,1.5,'purple','IT 104 - Introduction to Computing','{"OSI & TCP/IP Models","IPv4/IPv6 Subnetting","Cisco IOS Switch & Router Config","VLANs & Inter-VLAN Routing"}'),
('PE 201','Physical Education','PE 201 - Physical Education','Team sports, officiating rules, court strategy, and physical wellness conditioning.','Coach V','Sports Complex','University Gym','Fri 2:00 PM - 4:00 PM',2,'BSIT',40,25,'available','Minor','{"Fri"}',14,2,'orange','PE 102 - Rhythmic Activities','{"Athletic Conditioning","Sports Rules","Team Tactics","Sportsmanship"}'),
('IT 402','Human-Computer Interaction','IT 402 - Human-Computer Interaction','User experience analysis, wireframing, interface design principles, and usability testing.','Ms. Reyes','Design Building','Design Lab 105','Mon/Wed 1:00 PM - 2:30 PM',3,'BSIT',35,31,'available','Major','{"Mon","Wed"}',13,1.5,'orange','IT 104 - Introduction to Computing','{"Design Principles","User Personas","Interactive Prototyping","Accessibility"}'),
('IT 204','Object-Oriented Programming','IT 204 - Object-Oriented Programming','Encapsulation, inheritance, polymorphism, abstraction, and GUI application development.','Prof. Mendoza','Computing Building','Lab 302','Tue/Thu 8:00 AM - 9:30 AM',3,'BSCS',35,33,'available','Core','{"Tue","Thu"}',8,1.5,'teal','CS 102 - Computer Programming 1','{"Classes and Objects","Inheritance","Interfaces","Collections"}'),
('IT 208','Database Management Systems','IT 208 - Database Management Systems','Relational database modeling, normalization, SQL queries, and stored procedures.','Mr. Villanueva','Computing Building','Lab 304','Mon/Wed 10:00 AM - 11:30 AM',3,'BSIT',35,22,'available','Major','{"Mon","Wed"}',10,1.5,'green','CS 102 - Computer Programming 1','{"ERD Design","Normalization","SQL Joins","Transactions"}'),
('MATH 203','Discrete Mathematics','MATH 203 - Discrete Mathematics','Set theory, combinatorics, graph theory, recurrence relations, and induction.','Dr. Santos','Main Academic Building','Room 205','Mon/Wed 3:00 PM - 4:30 PM',3,'BSCS',30,30,'available','Core','{"Mon","Wed"}',15,1.5,'purple','MATH 101 - Mathematics in the Modern World','{"Sets and Functions","Induction","Combinatorics","Graph Theory"}'),
('ACC 101','Fundamentals of Accounting','ACC 101 - Fundamentals of Accounting','Basic accounting entries, bookkeeping, balance sheets, and financial logic.','Mrs. Lim','Business Building','Room 104','Fri 9:00 AM - 12:00 PM',3,'BSBA',40,19,'available','Elective','{"Fri"}',9,3,'green','None','{"Accounting Equation","Journalizing","Trial Balance","Financial Statements"}'),
('PHIL 102','Formal Logic','PHIL 102 - Formal Logic','Propositional logic, truth tables, syllogisms, and logical inferences.','Dr. Cruz','Arts Building','Room 209','Tue/Thu 2:00 PM - 3:30 PM',3,'BSCS',35,18,'available','Gen Ed','{"Tue","Thu"}',14,1.5,'blue','None','{"Propositions","Truth Tables","Inference","Deductive Proofs"}'),
('GE 105','Purposive Communication','GE 105 - Purposive Communication','Multimodal communication, technical report writing, academic presentations, and intercultural workplace communication.','Ms. Gomez','Arts Building','Room 108','Tue/Thu 12:00 PM - 1:30 PM',3,'BSBA',35,27,'available','Gen Ed','{"Tue","Thu"}',12,1.5,'teal','None','{"Communication in a Globalized World","Technical & Business Proposals","Data Visualization & Pitching","Research Presentation"}'),
('IT 299','Web Systems & Technologies','IT 299 - Web Systems & Technologies','Modern responsive web architecture, DOM manipulation, RESTful APIs, and full-stack deployment.','Engr. Bautista','Computing Building','Lab 305','Mon/Wed 8:30 AM - 10:00 AM',3,'BSIS',30,24,'available','Elective','{"Mon","Wed"}',8.5,1.5,'orange','IT 104 - Introduction to Computing','{"Semantic HTML5 & Modern CSS Grid","ES6+ JavaScript & Fetch API","Backend Node.js Fundamentals","Cloud Hosting & Security"}')
on conflict (code) do update set
  name=excluded.name,title=excluded.title,description=excluded.description,instructor=excluded.instructor,
  building=excluded.building,room=excluded.room,schedule_text=excluded.schedule_text,units=excluded.units,
  program_code=excluded.program_code,max_capacity=excluded.max_capacity,enrolled_count=excluded.enrolled_count,
  status=excluded.status,course_type=excluded.course_type,days=excluded.days,start_hour=excluded.start_hour,
  duration=excluded.duration,color=excluded.color,prerequisite=excluded.prerequisite,topics=excluded.topics,
  updated_at=now();

insert into enrollment_settings (id,mode,manual_status,start_date_time,end_date_time,academic_year,semester)
values (1,'manual','Open','2026-08-01T08:00:00+00','2026-12-15T23:59:00+00','2026 - 2027','1st Semester (Fall)')
on conflict (id) do update set mode=excluded.mode, manual_status=excluded.manual_status,
  start_date_time=excluded.start_date_time, end_date_time=excluded.end_date_time,
  academic_year=excluded.academic_year, semester=excluded.semester, updated_at=now();

insert into student_profile_data (profile_id,first_name,middle_name,last_name,phone,campus,address,guardian,avatar_url)
values ('00000000-0000-0000-0000-000000000001','Jannica Lhei','Barcenas','Andrade','+63 917 842 9104',
  'Naga Campus, Central Visayas','Poblacion, City of Naga, Cebu','Maria B. Andrade (+63 918 553 2019)',
  'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=300')
on conflict (profile_id) do update set first_name=excluded.first_name,middle_name=excluded.middle_name,
  last_name=excluded.last_name,phone=excluded.phone,campus=excluded.campus,address=excluded.address,
  guardian=excluded.guardian,avatar_url=excluded.avatar_url,updated_at=now();

insert into enrollments (id,student_id,course_id,program_code,status,date_submitted)
select v.id, '00000000-0000-0000-0000-000000000001'::uuid, c.id, 'BSIT', 'Approved', v.submitted
from (values
  ('10000000-0000-0000-0000-000000000001'::uuid,'CS 201','2026-08-18 09:15+00'::timestamptz),
  ('10000000-0000-0000-0000-000000000002'::uuid,'IT 315','2026-08-18 09:16+00'::timestamptz),
  ('10000000-0000-0000-0000-000000000003'::uuid,'PE 201','2026-08-18 09:18+00'::timestamptz)
) v(id,code,submitted) join courses c on c.code=v.code
on conflict (student_id,course_id) do update set status=excluded.status,date_submitted=excluded.date_submitted;

insert into notifications (profile_id,icon,text,target,unread)
values
  ('00000000-0000-0000-0000-000000000001','check_circle','Enrollment for 1st Sem AY 2026-2027 is now open!','enrollment',true),
  ('00000000-0000-0000-0000-000000000001','local_library','University Library clearance has been verified.','status',true),
  ('00000000-0000-0000-0000-000000000001','medical_services','Reminder: Submit Annual Physical Exam to Medical Clinic.','status',false)
on conflict do nothing;

