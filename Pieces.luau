local Pieces = {
	buffer.create(16),
	buffer.create(9),
	buffer.create(9),
	buffer.create(4),
	buffer.create(9),
	buffer.create(9),
	buffer.create(9)
}

buffer.writei8(Pieces[1], 4, 1)
buffer.writei8(Pieces[1], 5, 1)
buffer.writei8(Pieces[1], 6, 1)
buffer.writei8(Pieces[1], 7, 1)

buffer.writei8(Pieces[2], 0, 1)
buffer.writei8(Pieces[2], 3, 1)
buffer.writei8(Pieces[2], 4, 1)
buffer.writei8(Pieces[2], 5, 1)

buffer.writei8(Pieces[3], 2, 1)
buffer.writei8(Pieces[3], 3, 1)
buffer.writei8(Pieces[3], 4, 1)
buffer.writei8(Pieces[3], 5, 1)

buffer.writei8(Pieces[4], 0, 1)
buffer.writei8(Pieces[4], 1, 1)
buffer.writei8(Pieces[4], 2, 1)
buffer.writei8(Pieces[4], 3, 1)

buffer.writei8(Pieces[5], 1, 1)
buffer.writei8(Pieces[5], 2, 1)
buffer.writei8(Pieces[5], 3, 1)
buffer.writei8(Pieces[5], 4, 1)

buffer.writei8(Pieces[6], 1, 1)
buffer.writei8(Pieces[6], 3, 1)
buffer.writei8(Pieces[6], 4, 1)
buffer.writei8(Pieces[6], 5, 1)

buffer.writei8(Pieces[7], 0, 1)
buffer.writei8(Pieces[7], 1, 1)
buffer.writei8(Pieces[7], 4, 1)
buffer.writei8(Pieces[7], 5, 1)

local function CopyBuffer(Buffer)
	local BufferSize = buffer.len(Buffer)

	local NewBuffer = buffer.create(BufferSize)
	buffer.copy(NewBuffer, 0, Buffer, 0, BufferSize)

	return NewBuffer
end

function Pieces.NewPiece(Index, NewValue)
	local NewPiece = CopyBuffer(Pieces[Index])
	
	for i=0, buffer.len(NewPiece) - 1 do
		local Value = buffer.readi8(NewPiece, i)
		
		if Value > 0 then
			buffer.writei8(NewPiece, i, NewValue)
		end
	end
	
	return NewPiece
end

function Pieces.Rotate(Piece, Clockwise)
	local BufferSize = buffer.len(Piece)
	
	local RotatedPiece = buffer.create(BufferSize)
	local PieceSize = math.floor(math.sqrt(BufferSize))
	
	for Row=1, PieceSize do
		for Column=1, PieceSize do
			local Index = buffer.readi8(Piece, (Row - 1) * PieceSize + (Column - 1))
			buffer.writei8(RotatedPiece, 
				Clockwise and 
					((Column * PieceSize) - Row) or
					((PieceSize - Column) * PieceSize + Row) - 1, 
				Index)
		end
	end
	
	return RotatedPiece
end

return Pieces
