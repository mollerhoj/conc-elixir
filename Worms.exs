import :timer, only: [ sleep: 1 ]

# TODO: Should world know worm x,y ?
# Worm should update on its own, without being locked to steps by the world.


defmodule World do

  def init do
    worm1 = {spawn(Worm,:init,[2,1,3]),1,0,0}
    worm2 = {spawn(Worm,:init,[2,9,6]),2,1,0}
    worm3 = {spawn(Worm,:init,[3,2,7]),3,2,0}
    worms = [worm1,worm2,worm3]
    worms
  end

  def step(worms) do
    receive do
      {:move,pid} ->
        worms = move(worms,pid)
      after 10 ->
        Render.draw(worms)
        imform_step(worms)
    end
    step(worms)
  end

  def move([h|t],pid) do
    if elem(h,0) == pid do
      x = :random.uniform(10)-1
      y = :random.uniform(10)-1
      h = set_elem(h,2,x)
      h = set_elem(h,3,y)
    end
    [h | move(t,pid)]
  end

  def move([],pid) do
    []
  end

  def imform_step([h | t]) do
    elem(h,0) <- {:step,self}
    imform_step(t)
  end

  def imform_step([]) do
  end
end

defmodule Worm do

  def init seed1,seed2,seed3 do
    :random.seed seed1,seed2,seed3
    step
  end

  def step do
    receive do
      {:step,world} -> 
        sleep :random.uniform 1000
        world <- {:move,self}
    end
  step
  end
end

defmodule Render do
  def draw(t) do
    draw(t,9,9)
  end

  def draw(t,rows,cols) do
    0..cols |> Enum.each fn (e)-> draw_col(t,rows,e) end
    IO.puts "\e[11A"
  end

  def draw_col(t,rows,col) do
    0..rows |> Enum.each fn (e)-> draw_row(t,e,col) end
    IO.write "\n"
  end

  def draw_row([h|t],row,col) do
    if elem(h,2) == row && elem(h,3) == col do
      IO.write elem(h,1)
    else
      draw_row(t,row,col)
    end
  end

  def draw_row([],row,col) do
    IO.write "_"
  end
end

worms = World.init
World.step worms
