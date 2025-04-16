# Задание 1________________

SELECT c.ID_client,                                             -- ID клиента
		AVG (t.Id_check) AS avg_check,                          -- средний чек за период
        SUM(c.Total_amount)/12 AS avg_check_month,              -- средняя сумма покупок за месяц
        count(t.ID_client) AS count_transactions                 -- количество всех операций
FROM customer AS c
JOIN transactions AS t ON c.Id_client= t.ID_client               -- объединение таблиц 
WHERE t.date_new BETWEEN '2015-06-01'AND '2016-06-01'            -- фильтрация по периоду
GROUP BY c.ID_client                                             -- группировка по клиентам
HAVING COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) = 12     -- фильтрация покупок за каждый месяц в течении года
ORDER BY count_transactions DESC;                                -- сортировка по операциям по убыванию

# Задание 2 (1, 2, 3, 4)_________________

SELECT 
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,                     -- выводим месяцы в результирующей таблице
    AVG(t.Sum_payment) AS avg_check_amount,                        -- средня сумма чека
    COUNT(t.Id_check) / COUNT(DISTINCT MONTH(t.date_new)) AS avg_count_trans_month, -- среднее количество операций в месяц
    COUNT(DISTINCT t.ID_client) AS avg_clients_month,               -- количество клиентов
    COUNT(t.Id_check) / (SELECT COUNT(Id_check) FROM transactions
						WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS transactions_share,  -- доля операций за год
    SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions
						WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS amount_share          -- доля суммы в месяц от общей суммы
FROM transactions t
LEFT JOIN customer c ON t.ID_client = c.Id_client             -- объединяем таблицы по ID клиента
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'        -- фильтруем по периоду
GROUP BY DATE_FORMAT(t.date_new, '%Y-%m')                     -- группируем по месяцам
ORDER BY month ASC;                                           -- сортируем по месяцу от меньшего к бальшему

# Задание 2 (5)_________________
SELECT 
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,             -- выводим месяц
    Gender,                                                -- пол клиента 
    COUNT(DISTINCT t.ID_client) AS client_count,           -- количество клиентов по полам
    SUM(t.Sum_payment) AS total_spend,                     -- Общая сумма расходов по полам
    SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions
						WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS gender_spend_share  -- Доля расходов по полу
FROM transactions t
JOIN customer c ON t.ID_client = c.Id_client               -- объединяем таблицы по ID клиента
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'     -- фильтруем по периоду
GROUP BY DATE_FORMAT(t.date_new, '%Y-%m'), Gender          -- группируем по месяцам и полу клиентов
ORDER BY month ASC;                                        -- сортируем по месяцу от меньшего к бальшему

# Задание 3_________________
-- Сумма и количество операций за весь период
SELECT 
    CASE
        WHEN Age < 20 THEN '0-19'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+' 
    END AS age_group,                                     -- возрастная по возрастам
    COUNT(t.Id_check) AS total_transactions,              -- количество операций
    SUM(t.Sum_payment) AS total_amount                    -- сумму по каждой группе
FROM transactions t
JOIN customer c ON t.ID_client = c.Id_client              -- объединяем таблицы по ID клиента
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'    -- фильтруем по периоду
GROUP BY 1                                                -- группируем по группам (age_group)
ORDER BY age_group ASC;                                       -- сортируем по группам (age_group) от меньшего к большему

-- поквартальные-средние показатели и %
SELECT 
    CASE
        WHEN MONTH(t.date_new) BETWEEN 1 AND 3 THEN 'quarter_1'
        WHEN MONTH(t.date_new) BETWEEN 4 AND 6 THEN 'quarter_2'
        WHEN MONTH(t.date_new) BETWEEN 7 AND 9 THEN 'quarter_3'
        WHEN MONTH(t.date_new) BETWEEN 10 AND 12 THEN 'quarter_4'
    END AS quarter,                                            -- Определяем квартал
    CASE
        WHEN Age < 20 THEN '0-19'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+' 
    END AS age_group,                                           -- возрастная группа
    COUNT(t.Id_check) / COUNT(DISTINCT t.ID_client) AS count_transactions_client,   -- количество операций на клиента
    SUM(t.Sum_payment) / COUNT(DISTINCT t.ID_client) AS sum_client,                 -- сумма на клиента
    (SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions
							WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')) AS spend_percent  -- процент от общей суммы
FROM transactions t
JOIN customer c ON t.ID_client = c.Id_client                       -- объединяем таблицы по ID клиента
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'             -- фильтруем по периоду
GROUP BY 1, 2                                                      -- группируем кварталам и по группам (age_group) 
ORDER BY quarter ASC, age_group ASC;                               -- сортируем кварталам и по группам от меньшего к большему
