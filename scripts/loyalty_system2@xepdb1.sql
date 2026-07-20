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
