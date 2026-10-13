-- 핵심 SQL 15개 / PostgreSQL 18
-- 빈 검증 DB에서 schema.sql -> seed.sql 실행 후 번호 순으로 실행한다.
-- Q13: 닉네임 변경, Q14: 기록 1건 삭제, Q15: 인덱스 생성.
-- 기존 music_db에서 이미 수행한 Q14/Q15는 다시 실행하지 않는다.

-- Q01. 180초 이상인 곡을 긴 순으로 최대 5개 조회한다.
SELECT title, duration_seconds
FROM track
WHERE duration_seconds >= 180
ORDER BY duration_seconds DESC, id
LIMIT 5;

-- Q02. 2026년에 발매된 앨범을 최신순으로 조회한다.
SELECT title, release_date
FROM album
WHERE release_date >= DATE '2026-01-01'
  AND release_date < DATE '2027-01-01'
ORDER BY release_date DESC, id;

-- Q03. 제목에 In이 포함된 곡을 대소문자 구분 없이 조회한다. PostgreSQL 전용: ILIKE.
SELECT title, duration_seconds
FROM track
WHERE title ILIKE '%In%'
ORDER BY id;

-- Q04. 길이가 120초 미만이거나 240초 이상인 곡을 짧은 순으로 조회한다.
SELECT title, duration_seconds
FROM track
WHERE duration_seconds < 120 OR duration_seconds >= 240
ORDER BY duration_seconds ASC, id;

-- Q05. 곡과 해당 앨범 제목을 INNER JOIN으로 조회한다.
SELECT t.title AS track_title, a.title AS album_title
FROM track AS t
INNER JOIN album AS a ON t.album_id = a.id
ORDER BY t.id;

-- Q06. 각 재생 기록의 회원 닉네임과 재생 시각을 조회한다.
SELECT m.display_name AS member_name, ph.played_at
FROM play_history AS ph
INNER JOIN member AS m ON m.id = ph.member_id
ORDER BY ph.played_at, ph.id;

-- Q07. 재생 기록이 없는 곡도 포함해 모든 곡과 재생 시각을 조회한다.
SELECT t.title AS track_title, ph.played_at
FROM track AS t
LEFT JOIN play_history AS ph ON t.id = ph.track_id
ORDER BY t.id, ph.played_at, ph.id;

-- Q08. 곡 제목, 참여 가수, 참여 역할을 세 테이블을 연결해 조회한다.
SELECT t.title AS track_title, ar.name AS artist_name, tc.credit_type
FROM track_credit AS tc
INNER JOIN track AS t ON tc.track_id = t.id
INNER JOIN artist AS ar ON tc.artist_id = ar.id
ORDER BY t.id, ar.name;

-- Q09. 앨범별로 DB에 등록된 곡 수를 센다. 실제 전체 수록곡 수와 다르다.
SELECT a.id, a.title AS album_title, COUNT(t.id) AS track_count
FROM album AS a
LEFT JOIN track AS t ON a.id = t.album_id
GROUP BY a.id, a.title
ORDER BY a.id;

-- Q10. 재생 기록이 있는 회원별 총 청취 시간을 초 단위로 집계한다.
SELECT m.id, m.display_name AS member_name,
       SUM(ph.listened_seconds) AS total_listened_seconds
FROM member AS m
INNER JOIN play_history AS ph ON m.id = ph.member_id
GROUP BY m.id, m.display_name
ORDER BY total_listened_seconds DESC, m.id;

-- Q11. 앨범별 등록 곡의 평균 길이를 소수점 둘째 자리까지 구한다.
SELECT a.id, a.title AS album_title,
       ROUND(AVG(t.duration_seconds), 2) AS avg_duration_seconds
FROM album AS a
INNER JOIN track AS t ON a.id = t.album_id
GROUP BY a.id, a.title
ORDER BY avg_duration_seconds DESC, a.id;

-- Q12. 전체 곡의 평균 길이보다 긴 곡을 서브쿼리로 조회한다.
SELECT title, duration_seconds
FROM track
WHERE duration_seconds > (SELECT AVG(duration_seconds) FROM track)
ORDER BY duration_seconds DESC, id;

-- Q13. minxu01 회원의 닉네임 변경 (전후 확인).
SELECT id, username, display_name FROM member WHERE username = 'minxu01';
UPDATE member
SET display_name = '음악듣는민수'
WHERE username = 'minxu01';
SELECT id, username, display_name FROM member WHERE username = 'minxu01';

-- Q14. minxu01의 KGB 80초 청취 기록 한 건을 삭제한다.
-- 워크로그의 id=12 대신 업무 조건으로 대상을 찾아 새 DB에서도 재현한다.
-- PostgreSQL 전용: DELETE USING, TIMESTAMPTZ 리터럴, RETURNING.
DELETE FROM play_history AS ph
USING member AS m, track AS t, album AS a
WHERE ph.member_id = m.id
  AND ph.track_id = t.id
  AND t.album_id = a.id
  AND m.username = 'minxu01'
  AND a.title = 'PRIMA'
  AND t.title = 'KGB'
  AND ph.listened_seconds = 80
  AND ph.played_at = TIMESTAMPTZ '2026-10-10 12:00:00+09'
RETURNING ph.*;
SELECT COUNT(*) AS history_count FROM play_history; -- 12 -> 11

-- Q15. 회원별 최신 재생 기록 검색과 정렬을 돕기 위한 복합 인덱스 생성.
CREATE INDEX idx_play_history_member_played_at
ON play_history (member_id, played_at DESC);
-- PostgreSQL 시스템 뷰로 생성 여부 확인.
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND tablename = 'play_history'
  AND indexname = 'idx_play_history_member_played_at';
