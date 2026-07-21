-- Add test data
-- ========================================================================================

-- for clients
insert into clients (name)
select 'Client_' || level 
from dual 
connect by level <= 1000;                    -- Generation of 1000 clients (from Client_1 to Client_1000)

-- for purchases 

insert into purchases (client_id, purchase_date, amount, bonus_earned)
select
    mod(level, 1000) + 1,                    -- 50000 purchases for 1000 clients (50 to each)
    sysdate - mod(level, 100),               -- 50000 dates for each purchase for 
    round(dbms_random.value(100, 10000), 2), -- Price of each purchase (50000, from 100.00 to 99999.99)
    round(dbms_random.value(10, 1000), 0)    -- How many bonuses were earned for each purchase
from dual
connect by level <= 50000;

-- for bonus_transactions

insert into bonus_transactions (client_id, transaction_date, bonus_change, description)
select
    mod(level, 1000) + 1,                         -- 50000 bonus transaction for 1000 clients (50 to each)
    sysdate - mod(level, 200),                    -- 50000 dates for each bonus transaction
    case when mod(level, 5) = 0 then
             -50
         else
             round(dbms_random.value(10, 500), 0) -- |Every fifth purchase paid with bonuses (50 for example),| 
    end,                                          -- |others with money (so client gets bonuses)              |
    'Test transaction'                            -- Description
from dual
connect by level <= 50000;



