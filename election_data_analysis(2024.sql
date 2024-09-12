--5.total seats won by I.N.D.I.A alliance party
select 
	sum(case 
	when party in (
	'India National Congress - INC',
	'Aam Aadmi Party - AAAP',
	'All India  trinomool Congress - AITC',
	'Bharat Adivasi Party - BHRTADVSIP',
	'Communist Part Of India - (MARXIST) - CPI(M)'
	)THEN [Won]
	else 0
	end) as num_of_seats
	from partywise_result;
--6.individual number of seats won by INDIA alliance parties 
select party,Won
from partywise_result
where party in (
	'India National Congress - INC',
	'Aam Aadmi Party - AAAP',
	'All India  trinomool Congress - AITC',
	'Bharat Adivasi Party - BHRTADVSIP',
	'Communist Part Of India - (MARXIST) - CPI(M)'
	)
	order by Won desc;
--7.add new column field in the dable partywise_result to get alliance as NDA,INDIA,or other.
alter table partywise_result 
Add party_alliance varchar(100)

select * from partywise_result
update partywise_result 
set party_alliance='NDA' 
where party in (
					'Bharatiya Janata Party - BJP',
					'Telugu Desam - TDP',
					'Janata Dal  (United) - JD(U)',
					'Shiv Sena - SHS',
					'AJSU Party - AJSUP',
					'Apna Dal (Soneylal) - ADAl',
					'Asom Gana Parishad - AGP',
					'Hindustani Awam Morcha (Secular) - HAMS',
					'Janasena Party - Jnp',
					'Janata Dal  (Secular) - JD(S)',
					'Lok Janshakti Party(Ram Vilas) - LJPRV',
					'Nationalist Congress Party - NCP',
					'Rashtriya Lok Dal - RLD',
					'Sikkim Krantikari Morcha - SKM');
					update partywise_result 
update partywise_result
set party_alliance='I.N.D.I.A' 
where party in (
	'Indian National Congress - INC',
                'Aam Aadmi Party - AAAP',
                'All India Trinamool Congress - AITC',
                'Bharat Adivasi Party - BHRTADVSIP',
                'Communist Party of India  (Marxist) - CPI(M)',
                'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
                'Communist Party of India - CPI',
                'Dravida Munnetra Kazhagam - DMK',
                'Indian Union Muslim League - IUML',
                'Nat`Jammu & Kashmir National Conference - JKN',
                'Jharkhand Mukti Morcha - JMM',
                'Jammu & Kashmir National Conference - JKN',
                'Kerala Congress - KEC',
                'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
                'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
                'Rashtriya Janata Dal - RJD',
                'Rashtriya Loktantrik Party - RLTP',
                'Revolutionary Socialist Party - RSP',
                'Samajwadi Party - SP',
                'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
                'Viduthalai Chiruthaigal Katchi - VCK');
update partywise_result
set party_alliance='other'
where party_alliance is null;
--8.winning candidate name ,party name, total votes, and the margin of the victor
--for specific state and constituency?
select 
	cr.winning_candidate,
	pr.party,
	cr.total_votes,
	cr.margin,
	s.State,
	cr.Constituency_Name
	from constituencyWise_result cr
	inner join partywise_result pr
	on cr.Party_ID=pr.Party_ID
	inner join state_wise_result sr
	on cr.Parliament_Constituency=sr.Parliament_Constituency
	inner join States s
	on sr.State_ID= s.State_ID
	where	cr.Constituency_Name = 'AGRA';

--9.what is  distribution of  EVM votes  versus postal  votes for candidates in specific constituency;
select
	 cd.EVM_Votes ,
	 cd.Postal_Votes,
	 cd.Total_Votes,
	 cd.Candidate,
	 cr.Constituency_Name
	 from constituencyWise_result cr
	 inner join constituencywise_details cd
	 on cr.Constituency_ID=cd.Constituency_ID
	 where cr.Constituency_Name='RAJAMPET';


	 select * from constituencyWise_result
	 order by 
--10.which party won most seats in states and how many seats did each party won?
select 
	p.Party,
	count(cr.Constituency_ID) as  seats_won
	from constituencyWise_result cr
	inner join partywise_result p
	on cr.Party_ID=p.Party_ID
	join state_wise_result sr
	on cr.Parliament_Constituency=sr.Parliament_Constituency
	join States s
	on sr.State_ID=s.State_ID
	where s.state='Uttar Pradesh'
	group by  p.party
	order by seats_won desc;
--11.what is the total number of seats won by each party alliance (NDA,INDIA,Other)
select 
	s.state,
	sum(case when p.party_alliance='NDA' then 1 else 0 end) as NDA_seats,
	sum(case when p.party_alliance='I.N.D.I.A' then 1 else 0 end) as INDIA_seats,
	sum(case when p.party_alliance='others' then 1 else 0 end) as other_seats

	
	from constituencyWise_result cr
	inner join partywise_result p
	on cr.Party_ID=p.Party_ID
	join state_wise_result sr
	on cr.Parliament_Constituency=sr.Parliament_Constituency
	join States s
	on sr.State_ID=s.State_ID
	group by  s.state;
--12.which candidate received the highest number of votes  in each constituency (top 10):
WITH RankedCandidates AS (
    SELECT 
        cd.Constituency_ID,
        cd.Candidate,
        cd.Party,
        cd.EVM_Votes,
        cd.Postal_Votes,
        cd.EVM_Votes + cd.Postal_Votes AS Total_Votes,
        ROW_NUMBER() OVER (PARTITION BY cd.Constituency_ID ORDER BY cd.EVM_Votes + cd.Postal_Votes DESC) AS VoteRank
    FROM 
        constituencywise_details cd
    JOIN 
        constituencyWise_result cr ON cd.Constituency_ID = cr.Constituency_ID
    JOIN 
        state_Wise_result sr ON cr.Parliament_Constituency = sr.Parliament_Constituency
    JOIN 
        states s ON sr.State_ID = s.State_ID
    WHERE 
        s.State = 'Maharashtra'
)

SELECT 
    cr.Constituency_Name,
    MAX(CASE WHEN rc.VoteRank = 1 THEN rc.Candidate END) AS Winning_Candidate,
    MAX(CASE WHEN rc.VoteRank = 2 THEN rc.Candidate END) AS Runnerup_Candidate
FROM 
    RankedCandidates rc
JOIN 
    constituencywise_result cr ON rc.Constituency_ID = cr.Constituency_ID
GROUP BY 
    cr.Constituency_Name
ORDER BY 
    cr.Constituency_Name;
