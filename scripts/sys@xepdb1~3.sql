-- Creating 'loyalty' scheme

create user loyalty_system
    identified by loyalty1
    default tablespace users
    temporary tablespace temp
    quota unlimited on users
    account unlock;

-- Grant premission to create objects 

grant connect,
      resource,
      create view,
      create materialized view,
      create procedure,
      create sequence to loyalty_system;
      
drop table onus_transactions;