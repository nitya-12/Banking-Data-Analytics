#total transaction amount
select concat(round(sum(amount)/1000000 ), 'M') as 
Total_Transaction_Amount from crdr;

#Net Transaction Amount
SELECT 
    SUM(CASE WHEN trtype = 'Credit' THEN Amount ELSE 0 END) -
    SUM(CASE WHEN trtype = 'Debit' THEN Amount ELSE 0 END) AS net_transaction_amount
FROM crdr;

#bankwise total transaction amount
select bankname, concat(round((sum(amount)/1000000),2), 'M') as Total_Transaction_Amount
from crdr group by bankname order by total_transaction_amount desc;

#bank and branch wise total transaction amount
select bankname, branch, concat(round((sum(amount)/1000000),2), 'M') as Total_Transaction_Amount 
from crdr group by bankname, branch order by BankName;

#bankwise total debit amount
select bankname, concat(round((sum(amount)/1000000),2), 'M') as total_debit_amount 
from crdr where TrType="debit" group by BankName order by total_debit_amount desc;

#bankwise total credit amount
select bankname, concat(round((sum(amount)/1000000),2),'M') as total_credit_amount 
from crdr where TrType="credit" group by BankName order by total_credit_amount desc;

# highest sbi transactions by transaction type
select trtype, max(amount) as Highest_SBI_Transaction_For  
from crdr where BankName= 'state Bank of India' group by TrType;

#transaction amount of the bank having highest customers
select BankName, count(cname) customer_count, concat(round((sum(amount)/1000000),2), 'M')
 as Total_Transaction_Amount from crdr where BankName = 
(select BankName from crdr group by BankName order by count(CName) desc limit 1) group by BankName;

# top 5 customers by debit
select cname, round(sum(amount),2) debit_amount 
from crdr where TrType= 'debit' group by cname order by sum(amount) desc limit 5;

# top 5 customers by credit
select cname, round(sum(amount),2) credit_amount 
from crdr where TrType= 'credit' group by cname order by sum(amount) desc limit 5;

#Credit to Debit Ratio
SELECT 
    CAST(SUM(CASE WHEN trtype = 'Credit' THEN Amount ELSE 0 END) AS FLOAT) /
    NULLIF(SUM(CASE WHEN trtype = 'Debit' THEN Amount ELSE 0 END), 0) AS credit_debit_ratio
FROM crdr;



#view
drop view bank_view;
create view bank_view as select cname, trtype, amount from crdr;
select * from bank_view;

drop view Branch_Transaction;
#View for branch wise transcations
CREATE VIEW Branch_Transaction AS
SELECT 
    Branch,
    SUM(Amount) AS Total_Transaction_Amount,
    COUNT(*) AS Transaction_Count
FROM crdr
GROUP BY Branch;
SELECT * FROM Branch_Transaction;



#If Then Else statement
drop function statforamount;
delimiter //
create function statforamount (px int)
returns varchar(50)
deterministic
begin 
declare amount_stat varchar(50);
if px >3000 then set amount_stat= "High Risk";
else  set amount_stat = "Low Risk";
end if;
return amount_stat;
end //
delimiter ;
select statforamount (5000);



#stored procedure
drop procedure alldetails;
delimiter //
create procedure alldetails()
begin
select * from crdr;
end //
delimiter ;
call alldetails();


drop procedure Show_bank_transactions;
-- Transactions for a particular Bank
delimiter //
CREATE PROCEDURE Show_bank_transactions
    (Bank_Name VARCHAR(100))
BEGIN
    SELECT *
    FROM crdr
    WHERE BankName = Bank_Name;
END //
delimiter ;
call Show_bank_transactions ('HDFC Bank');


drop procedure Show_customer_data;
-- Displaying transactions of a particular customer
delimiter //
CREATE PROCEDURE Show_customer_data (CustomerName VARCHAR(100))
BEGIN
    SELECT *
    FROM crdr
    WHERE CName = CustomerName;
END //
delimiter ;
call Show_customer_data ('John Ford');
