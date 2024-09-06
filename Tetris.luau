local Tetris = {}

local BoardSizeX = 10
local BoardSizeY = 20

local Pieces = require(script.Pieces)

local function CopyBuffer(Buffer)
	local BufferSize = buffer.len(Buffer)

	local NewBuffer = buffer.create(BufferSize)
	buffer.copy(NewBuffer, 0, Buffer, 0, BufferSize)

	return NewBuffer
end

local IndexList = {}
for i=1, #Pieces do
	table.insert(IndexList, i)
end

local function GetRandomPiece()
	local IndexIndexList = math.random(1, #IndexList)
	local Index = IndexList[IndexIndexList]
	table.remove(IndexList, IndexIndexList)

	if #IndexList <= 0 then
		for i=1, #Pieces do
			table.insert(IndexList, i)
		end
	end

	return Pieces.NewPiece(Index, Index)
end

local function GetValue(Buffer, Index)
	return buffer.readi8(Buffer, Index)
end

function Tetris.new()
	local PieceCenter = math.floor(BoardSizeX / 2) - 1

	local MainGame = {
		buffer.create(BoardSizeX * BoardSizeY),
		GetRandomPiece(), -- current piece
		GetRandomPiece(),  -- next piece

		-1,			-- Piece pos Y
		PieceCenter  -- piece pos X
	}

	local function PieceIsValid(Piece, Y, X)
		local Board = MainGame[1]

		local PieceSize = buffer.len(Piece)
		PieceSize = math.floor(math.sqrt(PieceSize))

		local Min, Max = PieceSize, 0

		for PieceOffset=0, buffer.len(Piece) - 1 do
			if GetValue(Piece, PieceOffset) == 0 then
				continue
			end

			local OffsetX = PieceOffset % PieceSize

			if OffsetX < Min then
				Min = OffsetX
			elseif OffsetX > Max then
				Max = OffsetX
			end

			local Offset = (X + ((Y + 1) * BoardSizeX)) + 
				(BoardSizeX * math.floor(PieceOffset / PieceSize)) + 
				(PieceOffset % PieceSize)

			if Offset < 0 or Offset >= buffer.len(Board) or GetValue(Board, Offset) > 0 then
				return false
			end
		end

		if X + Min < 0 or X + Max > BoardSizeX - 1 then
			return false
		end
		return true
	end

	local function ClearLines()
		local ClearedLine = false

		for Y=BoardSizeY, 1, -1 do
			local LineClear = true

			for X=1, BoardSizeX do
				if GetValue(MainGame[1], ((Y - 1) * BoardSizeX) + (X - 1)) == 0 then
					LineClear = false
					break
				end
			end

			if not LineClear then
				continue
			end

			local NewBoard = buffer.create(buffer.len(MainGame[1]))

			if Y ~= 1 then
				buffer.copy(NewBoard, BoardSizeX, MainGame[1], 0, (Y - 1) * BoardSizeX)
			end

			if Y ~= BoardSizeY then
				local Offset = (Y) * BoardSizeX
				buffer.copy(NewBoard, Offset, MainGame[1], Offset, buffer.len(MainGame[1]) - Offset)
			end

			MainGame[1] = NewBoard
			ClearedLine = true
		end

		return ClearedLine
	end

	function MainGame:Step()
		if not PieceIsValid(MainGame[2], MainGame[4] + 1, MainGame[5]) then
			MainGame[1] = MainGame:GetBoard()
			MainGame[2] = MainGame[3]
			MainGame[3] = GetRandomPiece()
			MainGame[4] = -1
			MainGame[5] = PieceCenter

			if not PieceIsValid(MainGame[2], MainGame[4], MainGame[5]) then
				MainGame[6] = true
				return
			end

			repeat until not ClearLines()
		else
			MainGame[4] += 1
		end
	end

	function MainGame:Drop()
		repeat
			MainGame:Step()
		until MainGame[4] == -1
		return true
	end

	function MainGame:Rotate(Clockwise)
		local RotatedPiece = Pieces.Rotate(MainGame[2], Clockwise)

		if PieceIsValid(RotatedPiece, MainGame[4], MainGame[5]) then
			MainGame[2] = RotatedPiece
		end
	end

	function MainGame:Move(Side)
		if PieceIsValid(MainGame[2], MainGame[4], MainGame[5] + (Side and 1 or -1)) then
			MainGame[5] += (Side and 1 or -1)
		end
	end

	function MainGame:GetBoard()
		local Board = CopyBuffer(MainGame[1])
		local CurrentPiece = MainGame[2]

		local PiecePosY = MainGame[4]
		local PiecePosX = MainGame[5]

		local PieceSize = buffer.len(CurrentPiece)
		PieceSize = math.floor(math.sqrt(PieceSize))

		for PieceOffset=0, buffer.len(CurrentPiece) - 1 do
			local Value = GetValue(CurrentPiece, PieceOffset)
			if Value > 0 then
				local Offset = (PiecePosX + ((PiecePosY + 1) * BoardSizeX)) + 
					(BoardSizeX * math.floor(PieceOffset / PieceSize)) + 
					(PieceOffset % PieceSize)

				buffer.writei8(Board, Offset, Value)
			end
		end

		return Board
	end

	return MainGame
end

return Tetris
