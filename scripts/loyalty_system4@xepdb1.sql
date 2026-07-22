-- Analyzing the schedule to execute a regular request and MV request
-- ========================================================================================

-- Updating materialized view 
exec dbms_mview.refresh('MV_CLIENT_BONUS_STATS'); 

-- Default request

explain plan set statement_id = 'deafult_request' for
select
    c.id,
    c.name,
    coalesce(sum(p.amount), 0) as total_purchases,
    coalesce(count(p.id), 0) as purchase_count,
    coalesce(sum(p.bonus_earned), 0) -
    coalesce(abs(sum(case  
                        when bt.bonus_change < 0 then
                            bt.bonus_change
                        else
                            0
                     end)), 0) as total_bonus
from clients c
left outer join purchases p
           on   c.id = p.client_id and p.purchase_date >= sysdate - 30
left outer join bonus_transactions bt
           on   c.id = bt.client_id 
group by c.id,
         c.name
having coalesce(sum(p.bonus_earned), 0) -
       coalesce(abs(sum(case  
                            when bt.bonus_change < 0 then
                                bt.bonus_change
                            else
                                0
                        end)), 0) > 1000;
                        
select *
from table(dbms_xplan.display(null, 'deafult_request'));

-- MV request

explain plan set statement_id = 'mv_request' for
select * 
from mv_client_bonus_stats
where total_bonus > 1000;

select *
from table(dbms_xplan.display(null, 'mv_request'));






