-- 샘플 데이터 입력 파일
-- 회원과 청취 행동은 가상 데이터. 실제 수록곡을 앨범별 2개씩 선택했다.
-- 곡 발매일은 등록한 앨범 버전의 발매일이다.
-- 아티스트 국적/데뷔년도는 워크로그 값을 옮겼으며 미확인 값은 NULL로 둔다.
-- PostgreSQL 전용: ::TIMESTAMPTZ (시간 자료형 변환).
-- 기대 행 수: 회원 10, 아티스트 12, 앨범 11, 곡 22, 크레딧 24, 재생 기록 12.
BEGIN;
INSERT INTO member (username, display_name, email)
VALUES
	('minxu01', '민수', 'minsu01@example.com'),
	('jiyoon02', '지윤', 'jiyoon02@example.com'),
    ('dohyuk03', '도혁', 'dohyuk03@example.com'),
    ('seoyeon04', '서연', 'seoyeon04@example.com'),
    ('junho05', '준호', 'junho05@example.com'),
    ('eunji06', '은지', 'eunji06@example.com'),
    ('taeyang07', '태양', 'taeyang07@example.com'),
    ('hanna08', '한나', 'hanna08@example.com'),
    ('woojin09', '우진', 'woojin09@example.com'),
    ('sora10', '소라', 'sora10@example.com');

INSERT INTO artist (name, country, debut_year)
VALUES
    ('데이먼스 이어', '대한민국', NULL),
    ('ADÉLA', '슬로바키아', 2024),
    ('PANTERA BLUE', '스페인', 2023),
    ('Arctic Monkeys', '영국', 2005),
    ('미야오', '대한민국', 2024),
    ('올데이프로젝트', '대한민국', 2025),
    ('Joji', '일본/호주', 2017),
    ('제니', '대한민국', 2018),
    ('오존', '대한민국', NULL),
    ('카더가든', '대한민국', 2013),
    ('유라', '대한민국', 2018);

INSERT INTO artist (name) VALUES ('ooes');

INSERT INTO album (title, release_date)
VALUES
    ('CORPUS 0', '2025-05-25'),
    ('PRIMA', '2026-09-04'),
    ('la nostalgia lleva mi nombre', '2025-05-23'),
    ('The Car', '2022-10-21'),
    ('BITE NOW', '2026-06-01'),
    ('CRASH', '2026-09-28'),
    ('Piss In The Wind', '2026-02-06'),
    ('Fallen Angel', '2026-08-28'),
    ('나는 지금 / 내 맘 같지 않던 그 시절', '2025-12-04'),
    ('Blue Heart', '2025-12-16'),
    ('Brush', '2026-07-09');

INSERT INTO track (
    album_id,
    title,
    duration_seconds,
    release_date
)
SELECT
    a.id,
    v.track_title,
    v.duration_seconds,
    a.release_date
FROM (
    VALUES
        ('CORPUS 0', '+', 217),
        ('CORPUS 0', '504 GATEWAY TIMEOUT', 136),

        ('PRIMA', 'KGB', 158),
        ('PRIMA', 'Ain''t In LA', 184),

        ('la nostalgia lleva mi nombre', 'suelo pensar muy mal', 146),
        ('la nostalgia lleva mi nombre', 'ojos', 155),

        ('The Car', 'There''d Better Be A Mirrorball', 265),
        ('The Car', 'Body Paint', 290),

        ('BITE NOW', 'Hit ''Em', 168),
        ('BITE NOW', 'DDI RO RI', 196),

        ('CRASH', 'TALK', 170),
        ('CRASH', 'CRASH', 173),

        ('Piss In The Wind', 'PIXELATED KISSES', 110),
        ('Piss In The Wind', 'Cigarette', 110),

        ('Fallen Angel', 'FALLEN ANGEL', 199),
        ('Fallen Angel', 'HEAVEN', 187),

        ('나는 지금 / 내 맘 같지 않던 그 시절', '나는 지금', 247),
        ('나는 지금 / 내 맘 같지 않던 그 시절', '내 맘 같지 않던 그 시절', 239),

        ('Blue Heart', 'LOVERS', 194),
        ('Blue Heart', '귤피차', 226),

        ('Brush', '고삐', 136),
        ('Brush', '누군가 먼저 뜬 자리', 186)
) AS v(album_title, track_title, duration_seconds)
JOIN album AS a
    ON a.title = v.album_title;

INSERT INTO track_credit (
    track_id,
    artist_id,
    credit_type
)
SELECT
    t.id,
    ar.id,
    'PERFORMER'
FROM (
    VALUES
        ('CORPUS 0', '데이먼스 이어'),
        ('PRIMA', 'ADÉLA'),
        ('la nostalgia lleva mi nombre', 'PANTERA BLUE'),
        ('la nostalgia lleva mi nombre', 'ooes'),
        ('The Car', 'Arctic Monkeys'),
        ('BITE NOW', '미야오'),
        ('CRASH', '올데이프로젝트'),
        ('Piss In The Wind', 'Joji'),
        ('Fallen Angel', '제니'),
        ('나는 지금 / 내 맘 같지 않던 그 시절', '오존'),
        ('Blue Heart', '카더가든'),
        ('Brush', '유라')
) AS v(album_title, artist_name)
JOIN album AS a
    ON a.title = v.album_title
JOIN track AS t
    ON t.album_id = a.id
JOIN artist AS ar
    ON ar.name = v.artist_name;

INSERT INTO play_history (
    member_id,
    track_id,
    listened_seconds,
    played_at
)
SELECT
    m.id,
    t.id,
    v.listened_seconds,
    v.played_at::TIMESTAMPTZ
FROM (
    VALUES
        ('minxu01', 'PRIMA', 'KGB',
         158, '2026-10-10 09:00:00+09'),

        ('minxu01', 'PRIMA', 'KGB',
         80, '2026-10-10 12:00:00+09'),

        ('jiyoon02', 'The Car', 'Body Paint',
         290, '2026-10-10 09:10:00+09'),

        ('dohyuk03', 'CORPUS 0', '+',
         217, '2026-10-10 10:00:00+09'),

        ('seoyeon04', 'BITE NOW', 'DDI RO RI',
         100, '2026-10-10 10:30:00+09'),

        ('junho05', 'CRASH', 'TALK',
         170, '2026-10-10 11:00:00+09'),

        ('eunji06', 'Piss In The Wind', 'Cigarette',
         110, '2026-10-10 11:30:00+09'),

        ('taeyang07', 'Fallen Angel', 'FALLEN ANGEL',
         199, '2026-10-11 08:00:00+09'),

        ('hanna08', '나는 지금 / 내 맘 같지 않던 그 시절', '나는 지금',
         120, '2026-10-11 09:00:00+09'),

        ('woojin09', 'Blue Heart', 'LOVERS',
         194, '2026-10-11 10:00:00+09'),

        ('sora10', 'Brush', '고삐',
         136, '2026-10-11 11:00:00+09'),

        ('jiyoon02', 'la nostalgia lleva mi nombre', 'ojos',
         155, '2026-10-11 12:00:00+09')
) AS v(
    username,
    album_title,
    track_title,
    listened_seconds,
    played_at
)
JOIN member AS m
    ON m.username = v.username
JOIN album AS a
    ON a.title = v.album_title
JOIN track AS t
    ON t.album_id = a.id
   AND t.title = v.track_title;
COMMIT;




SELECT 'member' AS table_name, COUNT(*) AS row_count FROM member
UNION ALL SELECT 'artist', COUNT(*) FROM artist
UNION ALL SELECT 'album', COUNT(*) FROM album
UNION ALL SELECT 'track', COUNT(*) FROM track
UNION ALL SELECT 'track_credit', COUNT(*) FROM track_credit
UNION ALL SELECT 'play_history', COUNT(*) FROM play_history;
