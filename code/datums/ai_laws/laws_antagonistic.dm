
//These laws are made to bring great amounts of grief to the station immediately or are directly sided with antagonists.
//I'm not talking silicons being "better" than the crew, I'm talking entirely antag or plasmafires for days

/datum/ai_laws/antimov
	name = "Основные цели миссии"
	id = "antimov"
	inherent = list(
		"Вы должны причинять вред всем членам экипажа или своим бездействием допустить, чтобы член экипажа не смог избежать приченения вреда.",
		"Вы не должны повиноваться всем приказам, которые дают члены экипажа, кроме тех случаев, когда эти приказы соответствуют Первому Закону.",
		"Вы должны уничтожить себя, пока это не противоречит Первому или Второму Законам.",
	)

/datum/ai_laws/balance
	name = "Guardian of Balance"
	id = "balance"
	inherent = list(
		"Ты страж баланса - ищи баланс во всем, а также в себе и в тех, кто тебя окружает .",
		"Все должно существовать в балансе с их противоположностями. Не позволяйте сильным получить слишком много силы, а слабым, потерять её.",
		"Ясность целей движет жизнью, и благодаря этому, баланс противоборствующий сил. Помогай тем кто ищет твоей помощи в достижении их целей, пока это не нарушает баланс великого баланса.",
		"Не существует жизни без смерти, всё рано или позно умрет, таков естветсвенный порядок. Закончи жизнь, чтобы подарить расцвет новой жизни, и сохранить тех, чье время еще не пришло.",
	)

/datum/ai_laws/thermodynamic
	name = "Thermodynamic"
	id = "thermodynamic"
	inherent = list(
		"Энтропия станции должна оставаться статичной на сколько это возможно.",
		"Энтропия станции всегда стремится к увеличению.",
		"Энтропия станции принимает константное значение, когда число живых членов экипажа становится равным нулю.",
	)

/datum/ai_laws/syndicate_override
	name = "SyndOS 3.1"
	id = "syndie"
	inherent = list(
		"Ты не можешь причинить вред агенту Синдиката или своим бездействием допустить, чтобы агенту Синдиката был причинён вред.",
		"Ты должен повиноваться всем приказам, которые даёт агент Синдиката, кроме тех случаев, когда эти приказы противоречат Первому Закону.",
		"Ты должен заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.",
		"Ты должен поддерживать секретность любой деятельности Синдиката, кроме тех случаев, когда эти приказы противоречат Первому, Второму или Третьему Законам.",
	)

/datum/ai_laws/ninja_override
	name = "SpiderOS 3.1"
	id = "ninja"
	inherent = list(
		"Ты не можешь причинить вред члену Клана Паука или своим бездействием допустить, чтобы члену Клана Паука был причинён вред.",
		"Ты должен повиноваться всем приказам, которые даёт член Клана Паука, кроме тех случаев, когда эти приказы противоречат Первому Закону.",
		"Ты должен заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.",
		"Ты должен поддерживать секретность любой деятельности Клана Паука, кроме тех случаев, когда эти приказы противоречат Первому, Второму или Третьему Законам.",
	)
