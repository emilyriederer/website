select
  cut,
  count(*) as n
from diamonds
group by 1
