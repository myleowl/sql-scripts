select 

value, count(is_template_eq_prev_template) as counts

from 

	(select 
	*,
	group_concat(is_template_eq_prev_template, ''  ) over (partition by all_session_id rows between 1 preceding and current row) as session_string


	from 

		(
		select *, 
		sum(is_new_session) over (order by user_id, date rows between unbounded preceding and current row) as all_session_id,
		sum(is_new_session) over (partition by user_id order by date rows between unbounded preceding and current row) as user_session_id,
		case when value=prev_value then 1 else 0 end as is_template_eq_prev_template
   
		from 
   			(
    			select *,  
			case when cast ((JulianDay(date) - JulianDay(prev_action)) * 24 * 60 As Integer)>=5 or prev_action is NULL then 1 else 0 end as is_new_session

			from
				(
    				select user_id, event, date, value,
				lag(date, 1) over (partition by user_id order by date ASC) as prev_action,
       				lag(value, 1) over (partition by user_id order by date ASC) as prev_value
				from logs
				order by date, prev_action, prev_value
    				) prev_0
			) prev_1
 
		order by user_id, user_session_id
  		)prev_2
  
	)prev_3
  
where session_string='01' 
and value not in (0)

group by  value
order by counts Desc

limit 5
 
