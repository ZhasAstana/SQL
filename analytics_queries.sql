

-- Анализ клиентов, которые покупали каждый месяц в течение года

SELECT 
    c.ID_client AS клиент,
    AVG(t.Id_check) AS средний_чек,
    SUM(c.Total_amount) / 12 AS средние_покупки_в_месяц,
    COUNT(t.ID_client) AS всего_операций
FROM customer AS c
JOIN transactions AS t ON c.Id_client = t.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY c.ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) = 12
ORDER BY всего_операций DESC;


-- Месячная сводка: средний чек, транзакции, клиенты и доля операций

SELECT 
    DATE_FORMAT(t.date_new, '%Y-%m') AS месяц,
    AVG(t.Sum_payment) AS средний_чек,
    COUNT(t.Id_check) / COUNT(DISTINCT MONTH(t.date_new)) AS среднее_число_транзакций_в_месяц,
    COUNT(DISTINCT t.ID_client) AS число_клиентов,
    COUNT(t.Id_check) / (SELECT COUNT(Id_check) FROM transactions
                         WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS доля_операций,
    SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions
                         WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS доля_выручки
FROM transactions t
LEFT JOIN customer c ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY месяц
ORDER BY месяц ASC;


-- Анализ расходов по месяцам и полу клиентов

SELECT 
    DATE_FORMAT(t.date_new, '%Y-%m') AS месяц,
    c.Gender AS пол,
    COUNT(DISTINCT t.ID_client) AS число_клиентов,
    SUM(t.Sum_payment) AS всего_расходов,
    SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions
                          WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS доля_расходов
FROM transactions t
JOIN customer c ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY месяц, пол
ORDER BY месяц ASC;


-- Годовой анализ продаж по возрастным группам

SELECT 
    CASE
        WHEN Age < 20 THEN '0-19'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS возрастная_группа,
    COUNT(t.Id_check) AS всего_транзакций,
    SUM(t.Sum_payment) AS всего_выручка
FROM transactions t
JOIN customer c ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY возрастная_группа
ORDER BY возрастная_группа ASC;


-- Квартальный анализ расходов и транзакций по возрастным группам

SELECT 
    CASE
        WHEN MONTH(t.date_new) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(t.date_new) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(t.date_new) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(t.date_new) BETWEEN 10 AND 12 THEN 'Q4'
    END AS квартал,
    CASE
        WHEN Age < 20 THEN '0-19'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age BETWEEN 60 AND 69 THEN '60-69'
        ELSE '70+'
    END AS возрастная_группа,
    COUNT(t.Id_check) / COUNT(DISTINCT t.ID_client) AS транзакций_на_клиента,
    SUM(t.Sum_payment) / COUNT(DISTINCT t.ID_client) AS выручка_на_клиента,
    SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions
                          WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS процент_от_общей_выручки
FROM transactions t
JOIN customer c ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY квартал, возрастная_группа
ORDER BY квартал ASC, возрастная_группа ASC;
