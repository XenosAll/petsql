WITH calendar AS (
    SELECT
        '2022-01-01'::DATE + (n || ' day')::INTERVAL AS date_from_calendar
    FROM GENERATE_SERIES(0, 150) n
),
daily_active_users AS (
    SELECT
        DATE_TRUNC('day', date)::DATE AS date_from_calendar,
        COUNT(DISTINCT user_id) AS daily_active_users_cnt
    FROM userentry
    WHERE date >= '2022-01-01'
      AND date < '2023-01-01'
    GROUP BY DATE_TRUNC('day', date)::DATE
)
SELECT
    c.date_from_calendar,
    COALESCE(d.daily_active_users_cnt, 0) AS daily_active_users_cnt,
    MAX(COALESCE(d.daily_active_users_cnt, 0))
        OVER (
            ORDER BY c.date_from_calendar
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS max_dau_cnt,
    COALESCE(d.daily_active_users_cnt, 0)
        - MAX(COALESCE(d.daily_active_users_cnt, 0))
            OVER (
                ORDER BY c.date_from_calendar
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS diff_dau
FROM calendar c
LEFT JOIN daily_active_users d
    ON c.date_from_calendar = d.date_from_calendar
ORDER BY c.date_from_calendar;