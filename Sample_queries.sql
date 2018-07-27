Database code

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM country_club.Facilities
WHERE membercost != 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( * ) 
FROM country_club.Facilities
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT  facid,
		name AS 'facility name',
		membercost AS 'member cost',
		monthlymaintenance AS 'monthly maintenance'
FROM country_club.Facilities
WHERE membercost != 0
AND membercost < monthlymaintenance * 0.2 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM country_club.Facilities
WHERE facid in (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 	name AS 'facility name',
 		CASE WHEN monthlymaintenance > 100 THEN 'expensive'
 			 ELSE 'cheap' END AS 'monthly maintenance'
FROM country_club.Facilities
ORDER BY 'facility name'



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM country_club.Members

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT	CONCAT(m.firstname,' ', m.surname) as full_name,
		sub.name as facility	
FROM `Members` as m
JOIN
  	( SELECT f.name, 
  			b.memid
	FROM `Facilities` as f
	JOIN `Bookings`as b
	ON f.facid = b.facid
	WHERE f.facid IN (0,1) ) sub
WHERE m.memid = sub.memid
GROUP BY full_name



/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name,
	CONCAT(m.firstname,' ', m.surname) as full_name,
	CASE WHEN m.memid = 0 THEN f.guestcost * b.slots 
 			 ELSE f.membercost * b.slots END AS cost
FROM `Bookings` AS b
JOIN `Facilities` as f
	ON f.facid = b.facid
JOIN `Members` as m
	ON m.memid = b.memid
WHERE ((f.guestcost * b.slots > 30 AND m.memid = 0)
OR (f.membercost * b.slots > 30 AND m.memid != 0))
AND b.starttime LIKE '2012-09-14%'
ORDER BY cost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT *
FROM
(
SELECT	sub.name,
		CONCAT(m.firstname,' ', m.surname) as full_name,
		CASE WHEN m.memid = 0 THEN f.guestcost * b.slots 
 			 ELSE f.membercost * b.slots END AS cost
FROM `Members` as m
JOIN
  	(SELECT f.name, 
  			b.memid,
  			f.membercost,
  			f.guestcost,
  			b.starttime
	FROM `Facilities` as f
	JOIN `Bookings`as b
	ON f.facid = b.facid) sub
WHERE m.memid = sub.memid
AND sub.starttime LIKE '2012-09-14%') sub2
WHERE cost > 30 
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT *
FROM
	( SELECT f.name,
			 SUM(CASE WHEN m.memid = 0 THEN f.guestcost * b.slots 
	 			 ELSE f.membercost * b.slots END) AS revenue
FROM `Facilities` as f
JOIN `Bookings`as b
	ON f.facid = b.facid
JOIN `Members` as m
	ON m.memid = b.memid
GROUP BY f.name) sub
WHERE sub.revenue < 1000





