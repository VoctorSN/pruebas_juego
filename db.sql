CREATE TABLE `Users` (
                         `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                         `name` TEXT NULL,
                         UNIQUE KEY `user_name_unique` (`name`)
);

CREATE TABLE `Games` (
                         `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                         `created_at` DATETIME NULL,
                         `last_time_played` DATETIME NULL,
                         `space` SMALLINT UNIQUE NOT NULL,
                         `current_level` INT NOT NULL DEFAULT 0,
                         `total_deaths` INT NOT NULL DEFAULT 0,
                         `total_time` BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE `Settings` (
                            `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                            `game_id` BIGINT UNSIGNED NOT NULL,
                            `HUD_size` DOUBLE NOT NULL DEFAULT 0.0,
                            `control_size` DOUBLE NOT NULL DEFAULT 0.0,
                            `is_left_handed` BOOLEAN NOT NULL DEFAULT false,
                            `show_controls` BOOLEAN NOT NULL DEFAULT false,
                            `is_music_active` BOOLEAN NOT NULL DEFAULT true,
                            `is_sound_enabled` BOOLEAN NOT NULL DEFAULT true,
                            `game_volume` DOUBLE NOT NULL DEFAULT 0.0,
                            `music_volume` DOUBLE NOT NULL DEFAULT 0.0,
                            FOREIGN KEY (`game_id`) REFERENCES `Games` (`id`) ON DELETE CASCADE
);

CREATE TABLE `Achievements` (
                                `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                `title` TEXT NOT NULL,
                                `description` LONGTEXT NOT NULL,
                                `difficulty` SMALLINT NOT NULL,
                                UNIQUE KEY `achievements_title_unique` (`title`)
);

CREATE TABLE `Levels` (
                          `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                          `name` TEXT NOT NULL,
                          `difficulty` SMALLINT NOT NULL
);

CREATE TABLE `GameLevel` (
                             `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                             `level_id` BIGINT UNSIGNED NOT NULL,
                             `game_id` BIGINT UNSIGNED NOT NULL,
                             `completed` BOOLEAN NOT NULL DEFAULT 0,
                             `unlocked` BOOLEAN NOT NULL DEFAULT false,
                             `stars` SMALLINT NOT NULL DEFAULT 0,
                             `date_completed` DATETIME NULL,
                             `last_time_completed` DATETIME NULL,
                             `time` BIGINT NULL,
                             `deaths` INT NOT NULL DEFAULT 0,
                             FOREIGN KEY (`level_id`) REFERENCES `Levels` (`id`),
                             FOREIGN KEY (`game_id`) REFERENCES `Games` (`id`) ON DELETE CASCADE
);

CREATE TABLE `GameAchievement` (
                                   `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
                                   `game_id` BIGINT UNSIGNED NOT NULL,
                                   `achievement_id` BIGINT UNSIGNED NOT NULL,
                                   `date_achieved` DATETIME NULL,
                                   `achieved` BOOLEAN NOT NULL DEFAULT false,
                                   FOREIGN KEY (`game_id`) REFERENCES `Games` (`id`) ON DELETE CASCADE,
                                   FOREIGN KEY (`achievement_id`) REFERENCES `Achievements` (`id`)
);


INSERT INTO `Achievements` (`id`, `title`, `description`, `difficulty`) VALUES
                                                                            (1001, 'Completa el nivel 1', 'Has completado el nivel 1', 1),
                                                                            (1002, 'Completa todos los niveles', 'Has completado todos los niveles', 6),
                                                                            (1003, 'Nivel 4 superado', 'Has completado el nivel 4', 2),
                                                                            (1004, 'Speedrunner', 'Acaba el juego en menos de 300 segundos', 9),
                                                                            (1005, 'Sin morir', 'Completa el juego sin morir', 10),
                                                                            (1006, 'Estrellas de nivel 5', 'Encuentra todas las estrellas en el nivel 5', 5),
                                                                            (1007, 'Nivel 2 perfecto', 'Pásate el nivel 2 sin morir', 4),
                                                                            (1008, 'Nivel 6 en 5 seg', 'Completa el nivel 6 en menos de 5 segundos', 7);

INSERT INTO `Levels` (`name`, `difficulty`) VALUES
                                                ('tutorial-01', 1),
                                                ('tutorial-02', 1),
                                                ('tutorial-03', 2),
                                                ('tutorial-04', 2),
                                                ('tutorial-05', 3),
                                                ('level-01', 4),
                                                ('level-02', 4),
                                                ('level-03', 5),
                                                ('level-04', 5),
                                                ('level-05', 6),
                                                ('level-06', 6),
                                                ('level-07', 7),
                                                ('level-08', 8),
                                                ('level-99', 10);

DELIMITER $$

CREATE PROCEDURE `create_game_at_space` (IN `space_value` SMALLINT)
BEGIN
    DECLARE existing_game_id BIGINT;

    -- Check if there is already a game in the given space
    SELECT id INTO existing_game_id
    FROM Games
    WHERE space = space_value
    LIMIT 1;

    -- If a game exists, delete it (related rows will be deleted via ON DELETE CASCADE)
    IF existing_game_id IS NOT NULL THEN
        DELETE FROM Games WHERE id = existing_game_id;
    END IF;

    -- Insert a new game in the specified space
    INSERT INTO Games (
        created_at,
        space
    )
    VALUES (
               NOW(),
               space_value
           );

    -- Retrieve the ID of the newly inserted game
    SET @new_game_id = LAST_INSERT_ID();

    -- Insert default settings for the new game
    INSERT INTO Settings (game_id)
    VALUES (@new_game_id);

    -- Populate GameLevel with all levels for the new game
    INSERT INTO GameLevel (game_id, level_id)
    SELECT @new_game_id, id FROM Levels;

    -- Populate GameAchievement with all achievements for the new game
    INSERT INTO GameAchievement (game_id, achievement_id)
    SELECT @new_game_id, id FROM Achievements;
END$$

CREATE PROCEDURE `insert_settings_for_game` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_HUD_size` DOUBLE,
    IN `p_control_size` DOUBLE,
    IN `p_is_left_handed` BOOLEAN,
    IN `p_show_controls` BOOLEAN,
    IN `p_is_music_active` BOOLEAN,
    IN `p_is_sound_enabled` BOOLEAN,
    IN `p_game_volume` DOUBLE,
    IN `p_music_volume` DOUBLE
)
BEGIN
    INSERT INTO Settings (
        game_id,
        HUD_size,
        control_size,
        is_left_handed,
        show_controls,
        is_music_active,
        is_sound_enabled,
        game_volume,
        music_volume
    )
    VALUES (
               p_game_id,
               p_HUD_size,
               p_control_size,
               p_is_left_handed,
               p_show_controls,
               p_is_music_active,
               p_is_sound_enabled,
               p_game_volume,
               p_music_volume
           );
END$$

CREATE PROCEDURE `get_settings_by_game_id` (
    IN `p_game_id` BIGINT UNSIGNED
)
BEGIN
    SELECT
        id,
        game_id,
        HUD_size,
        control_size,
        is_left_handed,
        show_controls,
        is_music_active,
        is_sound_enabled,
        game_volume,
        music_volume
    FROM Settings
    WHERE game_id = p_game_id;
END$$

CREATE PROCEDURE `get_game_by_space` (
    IN `p_space` SMALLINT
)
BEGIN
    SELECT
        id,
        created_at,
        last_time_played,
        space,
        current_level,
        total_deaths,
        total_time
    FROM Games
    WHERE space = p_space
    LIMIT 1;
END$$

CREATE PROCEDURE `get_game_levels_by_game_id` (
    IN `p_game_id` BIGINT UNSIGNED
)
BEGIN
    SELECT
        gl.id,
        gl.game_id,
        gl.level_id,
        l.name AS level_name,
        l.difficulty AS level_difficulty,
        gl.completed,
        gl.unlocked,
        gl.stars,
        gl.date_completed,
        gl.last_time_completed,
        gl.time,
        gl.deaths
    FROM GameLevel gl
             INNER JOIN Levels l ON gl.level_id = l.id
    WHERE gl.game_id = p_game_id;
END$$

CREATE PROCEDURE `get_game_achievements_by_game_id` (
    IN `p_game_id` BIGINT UNSIGNED
)
BEGIN
    SELECT
        ga.id,
        ga.game_id,
        ga.achievement_id,
        a.title AS achievement_title,
        a.description AS achievement_description,
        a.difficulty AS achievement_difficulty,
        ga.date_achieved,
        ga.achieved
    FROM GameAchievement ga
             INNER JOIN Achievements a ON ga.achievement_id = a.id
    WHERE ga.game_id = p_game_id;
END$$

CREATE PROCEDURE `mark_achievement_as_achieved` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_achievement_id` BIGINT UNSIGNED
)
BEGIN
    UPDATE GameAchievement
    SET
        achieved = true,
        date_achieved = NOW()
    WHERE
        game_id = p_game_id AND
        achievement_id = p_achievement_id;
END$$

CREATE PROCEDURE `update_game_level_by_game_id_and_level_name` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_level_name` TEXT,
    IN `p_completed` BOOLEAN,
    IN `p_unlocked` BOOLEAN,
    IN `p_stars` SMALLINT,
    IN `p_date_completed` DATETIME,
    IN `p_last_time_completed` DATETIME,
    IN `p_time` BIGINT,
    IN `p_deaths` INT
)
BEGIN
    UPDATE GameLevel gl
        INNER JOIN Levels l ON gl.level_id = l.id
    SET
        gl.completed = p_completed,
        gl.unlocked = p_unlocked,
        gl.stars = p_stars,
        gl.date_completed = p_date_completed,
        gl.last_time_completed = p_last_time_completed,
        gl.time = p_time,
        gl.deaths = p_deaths
    WHERE
        gl.game_id = p_game_id AND
        l.name = p_level_name;
END$$

CREATE PROCEDURE `get_game_achievement_by_title_and_game_id` (
    IN `p_game_id` BIGINT UNSIGNED,
    IN `p_title` TEXT
)
BEGIN
    SELECT
        ga.id,
        ga.game_id,
        ga.achievement_id,
        a.title,
        a.description,
        a.difficulty,
        ga.date_achieved,
        ga.achieved
    FROM GameAchievement ga
             INNER JOIN Achievements a ON ga.achievement_id = a.id
    WHERE
        ga.game_id = p_game_id AND
        a.title = p_title;
END$$

DELIMITER ;

