-- Minetest 0.4 mod: chat_antiflood
-- prevent players from posting too much text to chat
--
-- See README.txt for licensing and other information.

chat_antiflood={
	limit=10000,
    limit_warn=500,
    limit_spaces="                                                            ",
	list={},
	formspec="size[6,3]"..
		"label[1,0;-- Flood limit warning --]"..
		"button_exit[2,2;2,.5;chat_antiflood_submit;OK]"
}
minetest.register_on_chat_message(function(name, message)
    if chat_antiflood.list[name]==nil then
        chat_antiflood.list[name]=0
    end
    chat_antiflood.list[name]=chat_antiflood.list[name]+string.len(message)

    if chat_antiflood.list[name]>chat_antiflood.limit then
        minetest.show_formspec(
            name,
            "chat_antiflood.form",
            chat_antiflood.formspec
        )
    end

    local hacker = false
    --if (string.match(message, ".*\n.*") ~= nil) or ( string.match(message, ".*\r.*") ~= nil ) then
    if
        string.find(message, "\n", 1, true) ~=nil or
        string.find(message, "\r", 1, true) ~=nil
    then
        hacker = true
    end
    if string.len(message)>chat_antiflood.limit_warn then
        hacker=true
    end
    if string.find(message, chat_antiflood.limit_spaces, 1, true) ~=nil  then
        hacker=true
    end
    if hacker then
        minetest.log("error", "Player "..name.." warned for chat tampering")
        local pos=minetest.get_player_by_name(name):getpos()
        minetest.chat_send_all("<"..name..">"..message.."\n*Player <"..name..">-- Chat tampering warning --" )
        return true
    end
    return
end)

minetest.register_on_player_receive_fields(
	function(player,formname,fields)
		if formname=="chat_antiflood.form" then
			if fields.chat_antiflood_submit then
				return
			else
				minetest.show_formspec(
					player:get_player_name(), formname,
					chat_antiflood.formspec
				)
			end
		end
	end
)
