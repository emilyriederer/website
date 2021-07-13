with
sample as ({query_sample}),
prices as (select id, cut, price from diamonds)
select prices.*
from
  prices
  inner join
  sample
  on
  prices.id = diamonds.id
