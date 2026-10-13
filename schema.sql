-- 음악 서비스 DB / PostgreSQL 18
-- 새 빈 DB에서 실행. 기존 music_db에 다시 실행하지 않는다.
-- 순서: schema.sql -> seed.sql -> queries.sql -> bonus.sql
-- PostgreSQL 자료형: TIMESTAMPTZ (시간대가 있는 시점).
-- 관계: album 1:N track, member 1:N play_history, track 1:N play_history
-- track과 artist는 track_credit을 통해 N:M 연결한다.

BEGIN;
CREATE TABLE member (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- id 자동 부여
	username VARCHAR(50) NOT NULL UNIQUE,
	display_name VARCHAR(100) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP -- 생략 시 현재 시점을 저장; 표시 시간대는 세션 설정에 따름
);

CREATE TABLE artist (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(100) NOT NULL UNIQUE,
	country VARCHAR(50),
	debut_year INTEGER,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE album (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	title VARCHAR(200) NOT NULL,
	release_date DATE,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE track (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    album_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    duration_seconds INTEGER NOT NULL CHECK (duration_seconds > 0),
    release_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_track_album
        FOREIGN KEY (album_id) REFERENCES album(id)
);

CREATE TABLE track_credit (
	track_id INTEGER NOT NULL,
	artist_id INTEGER NOT NULL,
	credit_type VARCHAR(30) NOT NULL,

	PRIMARY KEY (track_id, artist_id, credit_type),

	CONSTRAINT fk_track_credit_track
		FOREIGN KEY (track_id)
		REFERENCES track(id),

	CONSTRAINT fk_track_credit_artist
		FOREIGN KEY (artist_id)
		REFERENCES artist(id),

	CONSTRAINT ck_track_credit_type
		CHECK (credit_type IN (
			'PERFORMER',
			'FEATURED',
			'SONGWRITER',
			'COMPOSER',
			'PRODUCER',
			'MIXER'
		))
);

CREATE TABLE play_history (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	member_id INTEGER NOT NULL,
	track_id INTEGER NOT NULL,
	listened_seconds INTEGER NOT NULL CHECK (listened_seconds >= 0),
	played_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, 

	CONSTRAINT fk_play_history_member
		FOREIGN KEY (member_id)
		REFERENCES member(id),

	CONSTRAINT fk_play_history_track
		FOREIGN KEY (track_id)
		REFERENCES track(id)
);
COMMIT;
