drop database pharma;
create database pharma;
use pharma;


/*ADDING PRIMARY KEY TO MEMBER DIMENSION TABLE */
ALTER TABLE dim_member 
modify ﻿member_id varchar(45);
UPDATE dim_member
SET member_birth_date=STR_TO_DATE(member_birth_date,'%m/%d/%Y');
ALTER TABLE dim_member
ADD PRIMARY KEY (﻿member_id);

/*ADDING PRIMARY KEY TO DRUG DIMESION TABLE*/
ALTER TABLE dim_drug
modify ﻿drug_ndc VARCHAR(45);
ALTER TABLE dim_drug
ADD PRIMARY KEY (﻿drug_ndc);
ALTER TABLE dim_drug
modify drug_form_code VARCHAR(45);
ALTER TABLE dim_drug
modify drug_brand_generic_code VARCHAR(45);

/*ADDING PRIMARY KEY TO DRUG BRAND TABLE*/
ALTER TABLE dim_drug_brand
modify drug_brand_generic_code VARCHAR(45);
ALTER TABLE dim_drug_brand
ADD PRIMARY KEY (drug_brand_generic_code);
select * from dim_drug_brand;

-- ADDING PRIMARY KEY TO DRUG FORM TABLE
ALTER TABLE dim_drug_form
MODIFY drug_form_code varchar(45);
ALTER TABLE dim_drug_form
ADD PRIMARY KEY (drug_form_code);
ALTER TABLE dim_drug_form
MODIFY drug_form_desc varchar(45);

select * from dim_drug_form;

-- fact table
ALTER TABLE fact_billing
ADD transaction_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE fact_billing
MODIFY DRUG_NDC varchar(45);
ALTER TABLE fact_billing
MODIFY member_id varchar(45);
update fact_billing
set `fill_date`=STR_TO_DATE(`FILL_DATE`, '%m/%d/%Y');

-- Foreign keys for fact table

ALTER TABLE fact_billing
ADD FOREIGN KEY (DRUG_NDC)
REFERENCES dim_drug(﻿drug_ndc)
ON DELETE RESTRICT
ON UPDATE RESTRICT;


ALTER TABLE fact_billing
ADD FOREIGN KEY (member_id)
REFERENCES dim_member(﻿member_id)
ON DELETE RESTRICT
ON UPDATE RESTRICT;

-- foreign keys for dim_drug table

ALTER TABLE dim_drug
ADD FOREIGN KEY (drug_form_code)
REFERENCES dim_drug_form(drug_form_code)
ON DELETE RESTRICT
ON UPDATE RESTRICT;

ALTER TABLE dim_drug
ADD FOREIGN KEY (drug_brand_generic_code)
REFERENCES  dim_drug_brand(drug_brand_generic_code)
ON DELETE RESTRICT
ON UPDATE RESTRICT; 
---------------------------------------------------------------------------------------------------------------------
select dd.drug_name, count(dd.drug_name) as prescriptions
from dim_drug dd
join fact_billing fb
on dd.﻿drug_ndc=fb.DRUG_NDC
group by dd.drug_name;
-- ----------------﻿-------------------------------------------------------------------------------------------------

select count(distinct memb.﻿member_id) as total_prescriptions, sum(copay) as total_copay
 , sum(insurance) as total_insurancepaid, 
case when member_age >= 65 then '65_Plus' else 'less_65' end as Age_Group
from dim_member memb
join fact_billing fact
on memb.﻿member_id = fact.member_id
group by Age_Group;


------------------------------------------------------------------------------------------------------------------------
select  * from (
 select  b.member_id, mem.member_first_name, mem.member_last_name,  d.drug_name 
, fill_date as filldate
, insurance as insuraancepaid 
 , row_number () over (partition by mem.﻿member_id order by fill_date desc) as rn 
 
from dim_member mem 
 left join  fact_billing b
on  mem.﻿member_id = b.member_id
left join dim_drug d
on d.﻿drug_ndc=b.DRUG_NDC
) x
where rn = 1 ;	
