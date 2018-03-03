G =
	root:
		html: "<article><h2>Welcome!</h2><p>Please click Next to continue.</p></article>"
		prev: []
		next: ['r1']
		status: 'U'
		type: 'R'
	r1:
		html: "<article><h2>Part 1: Graphics</h2><img src='https://cdn.glitch.com/af29f83a-f749-48b2-9c76-0d60e29e3f45%2Fperf.png' alt=''><p>Text here...</p><img src='https://cdn.glitch.com/af29f83a-f749-48b2-9c76-0d60e29e3f45%2Fpendulum.gif' alt=''><p>More text here...</p><img src='https://cdn.glitch.com/af29f83a-f749-48b2-9c76-0d60e29e3f45%2Fgraph.png' alt=''></article>"
		prev: ['root']
		next: ['r2']
		status: 'U'
		type: 'R'
	r2:
		html: "<article><h2>Part 2: Video</h2><div class='alert alert-warning' role='alert'>Click Next to start the quiz. You must get at least 2 correct answers to unlock Part 3.</div><video src='https://cdn.glitch.com/af29f83a-f749-48b2-9c76-0d60e29e3f45%2FWikipedia_Edit_2014.webm.480p.mp4?1519852975134' controls></video></article>"
		prev: ['r1']
		next: ['r3']
		status: 'L'
		type: 'Q'
		q: [0,1,2]
		pass: 2
	r3:
		html: "<article><h2>Part 3: KaTeX</h2><div class='alert alert-danger' role='alert'>Click Next to start the test. You must get at least 4 correct answers to proceed.</div><p>With HTML subscript and superscript:</p><p>NaHCO<sub>3 (s)</sub> &rarr; Na<sup>+</sup><sub>(aq)</sub> + HCO<sub>3</sub><sup>-</sup><sub>(aq)</sub></p><p>With KaTeX:</p><p id='katex'></p></article>"
		prev: ['r2']
		next: ['end']
		status: 'L'
		type: 'T'
		q: [3,4,5,6,7]
		pass: 4
	end:
		html: "<article><h2>The End</h2><p>Congratulations! You have completed this course.</p></article>"
		prev: ['r3']
		next: []
		status: 'U'
		type: 'R'
Q = [
	{
		prompt: '1 - 1 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for quiz question #1.']
		explain: 'Explanation for quiz question #1.'
	}
	{
		prompt: '2 - 2 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for quiz question #2.']
		explain: 'Explanation for quiz question #2.'
	}
	{
		prompt: '3 - 3 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for quiz question #3.']
		explain: 'Explanation for quiz question #3.'
	}
	{
		prompt: '10 - 10 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for test question #1.']
		explain: 'Explanation for test question #1.'
	}
	{
		prompt: '20 - 20 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for test question #2.']
		explain: 'Explanation for test question #2.'
	}
	{
		prompt: '30 - 30 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for test question #3.']
		explain: 'Explanation for test question #3.'
	}
	{
		prompt: '40 - 40 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for test question #4.']
		explain: 'Explanation for test question #4.'
	}
	{
		prompt: '50 - 50 = ?'
		choices: ['0', '1', '2', '3']
		hints: ['Here is the hint for test question #5.']
		explain: 'Explanation for test question #5.'
	}
]

# Pre-process
main = $ '#main'
for k, node of G
	main.append node.html = $ node.html
here = G.root
here.html.addClass 'show'
qList = qIndex = null
mode = 'R'
katex.render 'f(x) = \\int_{-\\infty}^\\infty \\hat f(\\xi)\\,e^{2 \\pi i \\xi x} \\,d\\xi', $('#katex')[0]
body = $ 'body'

shuffle = (a) => # https://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array
	i = a.length
	while --i > 0
		j = 0 | Math.random()*(i+1)
		[a[i], a[j]] = [a[j], a[i]]
	a

# Event handlers
updateArrows = =>
	prev.toggleClass 'invisible', if mode == 'R' then here.prev.length<1 else qIndex<1
	next.toggleClass 'invisible', if mode == 'R' then here.next.length<1 else qIndex+1>=qList.length

prev = $('#prev').click =>
	if mode == 'R'
		if here.prev[0]
			here.html.removeClass 'show'
			here = G[here.prev[0]]
			here.html.addClass 'show'
	else if qIndex>0 # Test or review mode
		qList[qIndex].html.removeClass 'show'
		qIndex--
		qList[qIndex].html.addClass 'show'
	updateArrows()

done = $('#done').click =>
	if mode == 'T'
		ans = main.find '.radio:checked'
		blank = qList.length - ans.length
		if confirm (if blank then "You have #{blank} unanswered question(s).\n" else '')+'Are you sure?'
			mode = 'V'
			body.removeClass 'test'
				.addClass 'review'
			main.find '.radio'
				.prop 'disabled', yes
			score = main.find('.correct.radio:checked').length
			$('#status').text "#{score}/#{qList.length}"
			if score >= here.pass
				here.status = 'C'
				here.html.find('.alert').hide()
			done.text 'Done'
	else if confirm 'Are you sure?' # Exit review mode
		mode = 'R'
		body.removeClass 'review'
		for q in qList
			q.html.remove()
		here.html.addClass 'show'
		updateArrows()
		done.text 'Submit'

next = $('#next').click =>
	if mode == 'R'
		if here.type != 'R' and here.status != 'C' # Start test
			if confirm "Start #{if here.type == 'Q' then 'quiz' else 'test'}?"
				mode = 'T'
				body.addClass 'test'
				qList = here.q.map (q, n) =>
					{prompt, choices, hints, explain} = Q[q]
					html = $ """
					<article>
						<h3>Question #{n+1}</h3>
						<div class='row'>
							<div class='col-9'>
								<div class='card'>
									<div class='card-header'>#{prompt}</div>
									<div id='q#{n}' class='card-body'></div>
								</div>
							</div>
							<div class='col-3 hint'>
								<div class='card'>
									<div class='card-header' id='hintLabel#{n}'>
										<h5 class='mb-0'><button class='btn btn-link' data-toggle='collapse' data-target='#hint#{n}' aria-expanded='true' aria-controls='hint#{n}'>Hint</button></h5>
									</div>
									<div id='hint#{n}' class='collapse' aria-labelledby='hintLabel#{n}'>
									  <div class='card-body'>#{hints[0]}</div>
									</div>
								</div>
							</div>
							<div class='col-3 explain'>
								<div class='card'>
									<div class='card-header' id='explainLabel#{n}'>
										<h5 class='mb-0'><button class='btn btn-link' data-toggle='collapse' data-target='#explain#{n}' aria-expanded='true' aria-controls='explain#{n}'>Explanation</button></h5>
									</div>
									<div id='explain#{n}' class='collapse' aria-labelledby='explainLabel#{n}'>
									  <div class='card-body'>#{explain}</div>
									</div>
								</div>
							</div>
						</div>
					</article>"""
					.appendTo main
					html.find "#q#{n}"
					.append shuffle choices.map (txt, a) =>
						$ """
						<div class='form-check#{if a==0 then ' correct' else ''}'>
							<input class='form-check-input radio#{if a==0 then ' correct' else ''}' type='radio' name='q#{n}' id='q#{n}a#{a}' value='#{a}'>
							<label class='form-check-label' for='q#{n}a#{a}'>#{txt}</label>
						</div>"""
					{html}
				qIndex = 0
				here.html.removeClass 'show'
				qList[qIndex].html.addClass 'show'
		else if here.next[0]
			here.html.removeClass 'show'
			here = G[here.next[0]]
			here.html.addClass 'show'
			if here.status == 'U'
				here.status = 'R'
			# Set here.next[].status?
	else if qIndex<qList.length # Test or review mode
		qList[qIndex].html.removeClass 'show'
		qIndex++
		qList[qIndex].html.addClass 'show'
	updateArrows()
