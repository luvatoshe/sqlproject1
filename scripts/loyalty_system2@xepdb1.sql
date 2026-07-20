drop type t_client_bonus_table;
-- Create a type to return from function
-- ========================================================================================    

create or replace type t_client_bonus_obj as object (
    client_id           number,
    client_name         varchar2(100),
    total_bonus         number,
    total_purchase_30d number, 
    purchase_count_30d  number
);
/
  
-- Create a tabular type for collection

create or replace type t_client_bonus_table as table of t_client_bonus_obj;
/

-- Pipeline function to get clients with bonuses > 1000

create or replace function get_clients_with_more_1000_bonus(p_date date default sysdate)
return t_client_bonus_table pipelined
as
    cursor c_client_bonus_table
    is
    select client_id,
           client_name,
           total_bonus,
           total_purchase_30d,
           purchase_count_30d
    from mv_client_bonus_stats
    where total_bonus > 1000
    order by total_bonus desc;
    
begin
    for r in c_client_bonus_table loop
        pipe row (t_client_bonus_obj(
            r.client_id,
            r.client_name,
            r.total_bonus,
            r.total_purchase_30d,
            r.purchase_count_30d
        ));
        end loop;
        
        return;
        
end get_clients_with_more_1000_bonus;
/

-- ======================================================================================== 
-- Penalty for inactive clients 
-- ========================================================================================   

create or replace procedure apply_inactivity_penalty
as
    v_penalty_amount  constant number := 10;
    v_cutoff_date     date := sysdate - 45;
    description     varchar2(4000);
    
    cursor c_penalty_clients
    is
    select c.id,
           c.name,
           coalesce(sum(p.bonus_earned), 0) -
           coalesce(abs(sum(case when bt.bonus_change < 0 then
                                    bt.bonus_change
                                 else
                                    0
                            end)), 0) as current_bonus
    from clients c
    left outer join purchases p
               on   c.id = p.client_id and p.purchase_date > v_cutoff_date
    left outer join bonus_transactions bt
               on   c.id = bt.client_id
    where not exists (
        select 1
        from purchases p2
        where p2.client_id = c.id
        and p2.purchase_date > v_cutoff_date
        )
        group by c.id,
                 c.name
        having coalesce(sum(p.bonus_earned), 0) -
               coalesce(abs(sum(case when bt.bonus_change < 0 then
                                        bt.bonus_change
                                     else
                                        0
                                end
                        )), 0)
                >= 10
        ;
begin
    for r in c_penalty_clients loop
        insert into bonus_transactions (
            client_id,
            transaction_date,
            bonus_change,
            description
         ) values (
            r.id,
            sysdate,
            -v_penalty_amount,
            'Daily fine for being inactive for 45 days'
        );
    end loop;   
end apply_inactivity_penalty;
/
