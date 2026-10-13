-- PostgreSQL 18 / queries.sql 실행 후 절별로 진행한다.
-- B02는 의도적인 오류이므로 전체 파일 일괄 실행은 피한다.

-- B01-A. 한 번이라도 재생된 곡: JOIN + DISTINCT.
SELECT DISTINCT t.id, t.title
FROM track AS t
INNER JOIN play_history AS ph ON ph.track_id = t.id
ORDER BY t.id;

-- B01-B. 같은 요구를 IN 서브쿼리로 해결한다.
SELECT t.id, t.title
FROM track AS t
WHERE t.id IN (SELECT ph.track_id FROM play_history AS ph)
ORDER BY t.id;
-- JOIN은 연결 결과의 중복을 DISTINCT로 제거한다.
-- IN은 ID 포함 여부를 판단하므로 바깥 track 행을 중복 생성하지 않는다.

-- B02. 실제 회원과 존재하지 않는 곡 ID로 FK 오류를 확인한다.
-- BEGIN, INSERT 순으로 실행. 오류를 저장한 뒤 같은 탭에서 ROLLBACK 실행.
-- 기대 오류: fk_play_history_track 위반, SQLSTATE 23503.
BEGIN;
INSERT INTO play_history (member_id, track_id, listened_seconds)
VALUES ((SELECT MIN(id) FROM member), -1, 30);
ROLLBACK;
-- 원인: track에 -1이 없다. 해결: 실제 존재하는 track.id를 사용한다.

-- B03 준비. 지표 비교용 가상 반복 청취 기록 6건 추가.
-- PostgreSQL 전용: ::TIMESTAMPTZ. 같은 회원/곡/시각이 있으면 재입력하지 않는다.
INSERT INTO play_history (
    member_id,
    track_id,
    listened_seconds,
    played_at
)
SELECT
    m.id,
    t.id,
    t.duration_seconds,
    v.played_at::TIMESTAMPTZ
FROM (
    VALUES
        ('PRIMA', 'KGB', '2026-10-11 13:00:00+09'),
        ('PRIMA', 'KGB', '2026-10-12 09:00:00+09'),
        ('PRIMA', 'KGB', '2026-10-12 15:00:00+09'),

        ('The Car', 'Body Paint', '2026-10-11 14:00:00+09'),
        ('The Car', 'Body Paint', '2026-10-12 10:00:00+09'),

        ('Blue Heart', 'LOVERS', '2026-10-12 11:00:00+09')
) AS v(album_title, track_title, played_at)
JOIN member AS m
    ON m.username = 'minxu01'
JOIN album AS a
    ON a.title = v.album_title
JOIN track AS t
    ON t.album_id = a.id
   AND t.title = v.track_title
WHERE NOT EXISTS (
    SELECT 1 FROM play_history AS existing
    WHERE existing.member_id = m.id
      AND existing.track_id = t.id
      AND existing.played_at = v.played_at::TIMESTAMPTZ
);

-- B03-1. 가장 많이 재생된 곡 TOP 5.
SELECT t.id, t.title, COUNT(*) AS play_count
FROM play_history AS ph
JOIN track AS t ON t.id = ph.track_id
GROUP BY t.id, t.title
ORDER BY play_count DESC, t.id
LIMIT 5;

-- B03-2. 회원별 총 청취 시간 (분).
SELECT m.id, m.display_name,
       ROUND(SUM(ph.listened_seconds) / 60.0, 2) AS total_minutes
FROM play_history AS ph
JOIN member AS m ON m.id = ph.member_id
GROUP BY m.id, m.display_name
ORDER BY total_minutes DESC, m.id;

-- B03-3. 날짜별 전체 재생 횟수 (곡별로 나누지 않음).
-- PostgreSQL 전용: AT TIME ZONE, ::DATE.
SELECT (played_at AT TIME ZONE 'Asia/Seoul')::DATE AS play_date,
       COUNT(*) AS play_count
FROM play_history
GROUP BY (played_at AT TIME ZONE 'Asia/Seoul')::DATE
ORDER BY play_date;

-- 추가 연습: 날짜별/곡별 재생 횟수. 위 지표와 집계 단위가 다르다.
SELECT t.title,
       (ph.played_at AT TIME ZONE 'Asia/Seoul')::DATE AS play_date,
       COUNT(*) AS play_count
FROM play_history AS ph
JOIN track AS t ON ph.track_id = t.id
GROUP BY t.id, t.title, (ph.played_at AT TIME ZONE 'Asia/Seoul')::DATE
ORDER BY play_date, t.id;
