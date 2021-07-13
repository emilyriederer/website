select
  cut,
  count(*) as n
from diamonds
where price < {max_price}
group by 1
