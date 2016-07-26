require 'apa102_rbpi'
require 'chroma'
require 'pry'
require 'rmagick'

include Apa102Rbpi
include Magick

Apa102Rbpi.configure do |c|
  c.num_leds = 600
  c.spi_hz = 2_000_000
end

start = 3
offset = 82

@entire_strip = Apa102Rbpi.strip

@strip1 = Apa102Rbpi::Strip.new([start, start + offset])
start = start + offset + 1

@strip2 = Apa102Rbpi::Strip.new([start, start + offset])
start = start + offset + 1

@strip3 = Apa102Rbpi::Strip.new([start, start + offset])
start = start + offset + 1

@strip4 = Apa102Rbpi::Strip.new([start, start + offset])
start = start + offset + 1

@strip5 = Apa102Rbpi::Strip.new([start, start + offset])
start = start + offset + 1

@strip6 = Apa102Rbpi::Strip.new([start, start + offset])
start = start + offset + 1

@strip7 = Apa102Rbpi::Strip.new([start, start + offset])

@strips = [@strip1, @strip2, @strip3, @strip4, @strip5, @strip6, @strip7]

def mirror_and_reverse_strips
  @strips.each { @strip1.mirror(strip) }
  @strip2.reverse
  @strip4.reverse
  @strip6.reverse
end

def unmirror_strips
  @strips.each { |strip| strip.mirrors.clear }
end

def clear_strip
  @entire_strip.clear
end

def show_strip
  @entire_strip.show!
end

def make_palette_from_base_color(base_color = 'blue', num_colors = 64, slice_by = 359)
  base_color.paint.palette.analogous(size: num_colors, slice_by: slice_by)
end

def color_wheel_palette(n, color_array)
  directional = n % (color_array.length * 2)
  direction = (directional < color_array.length) # flip flop between true and false
  array_index = (n % color_array.length)

  return color_array[array_index].to_hex.gsub('#', '0x').hex if direction == true
  return color_array.reverse[array_index].to_hex.gsub('#', '0x').hex if direction == false
end

class LightController

  def initialize(strip, hz = 40)
    @strip = strip
    @hz = hz
  end

  def magic_rainbow_tunnel(length = rand(5..15), interval = rand(1..3))
    sleep_time = 1.0 / @hz
    counter = 0
    color = %w(purple red blue green pink).sample
    color_array = make_palette_from_base_color(color)

    @strip.num_leds.times do |offset|
      @strip.clear

      (0..(@strip.num_leds / 9 - 1)).each do |snake_pos|
        offset_sub = -offset
        lit_pixel = (offset + snake_pos) % @strip.num_leds
        opp_lit_pixel = (offset + snake_pos + @strip.num_leds * 3 / 4) % @strip.num_leds
        lit_pixel2 = (offset + snake_pos + @strip.num_leds / 2) % @strip.num_leds
        opp_lit_pixel2 = (offset + snake_pos + @strip.num_leds / 4) % @strip.num_leds
        @strip.set_pixel(lit_pixel,
          color_wheel_palette((((counter * (interval)) & 255) * -1 + offset_sub), color_array),
        [(31 / (1 + 2 * (length - snake_pos).abs)), 1].max)
        @strip.set_pixel(opp_lit_pixel,
          color_wheel_palette((((counter * (interval)) & 255) * -1 + offset_sub), color_array),
        [(31 / (1 + 2 * (length - snake_pos).abs)), 1].max)
        @strip.set_pixel(lit_pixel2,
          color_wheel_palette((((counter * (interval)) & 255) * -1 + offset_sub), color_array),
        [(31 / (1 + 2 * (length - snake_pos).abs)), 1].max)
        @strip.set_pixel(opp_lit_pixel2,
          color_wheel_palette((((counter * (interval)) & 255) * -1 + offset_sub), color_array),
        [(31 / (1 + 2 * (length - snake_pos).abs)), 1].max)
        lit_pixel8 = (offset + snake_pos + @strip.num_leds / 8) % @strip.num_leds
        opp_lit_pixel8 = (offset + snake_pos + @strip.num_leds * 3 / 8) % @strip.num_leds
        lit_pixel82 = (offset + snake_pos + @strip.num_leds * 5 / 8) % @strip.num_leds
        opp_lit_pixel82 = (offset + snake_pos + @strip.num_leds * 7 / 8) % @strip.num_leds
        @strip.set_pixel(lit_pixel8,
          color_wheel(((counter * (interval)) & 255) + offset),
        [(31 / (1 + (length - snake_pos).abs)), 30].max)
        @strip.set_pixel(opp_lit_pixel8,
          color_wheel(((counter * (interval)) & 255) + offset),
        [(31 / (1 + (length - snake_pos).abs)), 30].max)
        @strip.set_pixel(lit_pixel82,
          color_wheel(((counter * (interval)) & 255) + offset),
        [(31 / (1 + (length - snake_pos).abs)), 30].max)
        @strip.set_pixel(opp_lit_pixel82,
          color_wheel(((counter * (interval)) & 255) + offset),
        [(31 / (1 + (length - snake_pos).abs)), 30].max)
        counter += 1
      end
      @strip.show!
      sleep sleep_time
    end
  end

  def magic_rainbow_tunnel2(length = rand(2..8), interval = rand(10..20))
    sleep_time = 1.0 / @hz
    counter = 0
    color = %w(purple red blue green pink).sample
    color_array = make_palette_from_base_color(color)

    @strip.num_leds.times do |offset|
      @strip.num_leds.times do |dark_pixel|
        @strip.set_pixel(dark_pixel, 0)
      end

      (0..(@strip.num_leds / 7 - 1)).each do |snake_pos|
        offset_sub = -offset
        lit_pixel = (offset + snake_pos) % @strip.num_leds
        opp_lit_pixel = (offset + snake_pos + @strip.num_leds * 3 / 4) % @strip.num_leds
        lit_pixel2 = (offset + snake_pos + @strip.num_leds / 2) % @strip.num_leds
        opp_lit_pixel2 = (offset + snake_pos + @strip.num_leds / 4) % @strip.num_leds
        @strip.set_pixel(lit_pixel,
          color_wheel(((counter * (interval)) & 255) * -1 + offset_sub),
        [(31 / (1 + (length - snake_pos).abs)), 4].max)
        @strip.set_pixel(opp_lit_pixel,
          color_wheel(((counter * (interval)) & 255) * -1 + offset_sub),
        [(31 / (1 + (length - snake_pos).abs)), 4].max)
        @strip.set_pixel(lit_pixel2,
          color_wheel(((counter * (interval)) & 255) * -1 + offset_sub),
        [(31 / (1 + (length - snake_pos).abs)), 4].max)
        @strip.set_pixel(opp_lit_pixel2,
          color_wheel(((counter * (interval)) & 255) * -1 + offset_sub),
        [(31 / (1 + (length - snake_pos).abs)), 4].max)
        lit_pixel8 = (offset + snake_pos + @strip.num_leds / 8) % @strip.num_leds
        opp_lit_pixel8 = (offset + snake_pos + @strip.num_leds * 3 / 8) % @strip.num_leds
        lit_pixel82 = (offset + snake_pos + @strip.num_leds * 5 / 8) % @strip.num_leds
        opp_lit_pixel82 = (offset + snake_pos + @strip.num_leds * 7 / 8) % @strip.num_leds
        @strip.set_pixel(lit_pixel8,
          color_wheel_palette((((counter * (interval)) & 255) + offset), color_array),
        [(31 / (1 + (length - snake_pos).abs)), 28].max)
        @strip.set_pixel(opp_lit_pixel8,
          color_wheel_palette((((counter * (interval)) & 255) + offset), color_array),
        [(31 / (1 + (length - snake_pos).abs)), 28].max)
        @strip.set_pixel(lit_pixel82,
          color_wheel_palette((((counter * (interval)) & 255) + offset), color_array),
        [(31 / (1 + (length - snake_pos).abs)), 28].max)
        @strip.set_pixel(opp_lit_pixel82,
          color_wheel_palette((((counter * (interval)) & 255) + offset), color_array),
        [(31 / (1 + (length - snake_pos).abs)), 28].max)
        counter += 1
      end
      @strip.show!
      sleep sleep_time
    end
    counter += 1
  end

  def picture_twinkle(pixels, repeat = 5)
    n ||= 1
    switch = -1
    repeat.times do
      n += rand(-5..5)
      switch = -switch
      (3..31).each do |b|
        n += switch
        pixels.each_with_index do |rgb, index|
          @strip.set_pixel(index + n, rgb, (rand(b)))
          @strip.set_pixel(index, 0) if rand(100) > 90
        end
        @strip.show!
        sleep(1 / (rand(20) + 20).to_f)
      end
      (3..31).reverse_each do |b|
        n += switch
        pixels.each_with_index do |rgb, index|
          @strip.set_pixel(index + n, rgb, (rand(b)))
          @strip.set_pixel(index, 0) if rand(100) > 90
        end
        @strip.show!
        sleep(1 / (rand(20) + 20).to_f)
      end
    end
  end

  def palette_painter_fast(repeat = 10)
    color = %w(purple red blue green pink).sample
    color_array = make_palette_from_base_color(color)
    n ||= 1
    repeat.times do
      n += 1
      @strip.each do |strip|
        n += 1
        strip.set_all_pixels(color_wheel_palette(n, color_array), rand(10) + 20)
        (1..strip.num_leds).each do |p|
          strip.set_pixel(p, 0) if rand(100) > 70
        end
        strip.show!
        sleep (1 / @hz)
      end
    end
  end

  def palette_painter_slow(repeat = 10)
    color = %w(purple red blue green pink).sample
    color_array = make_palette_from_base_color(color)
    n ||= 1
    repeat.times do
      n += 1
      @strip.each do |strip|
        n += 1
        strip.set_all_pixels(color_wheel_palette(n, color_array), rand(10) + 20)
        (1..strip.num_leds).each do |p|
          strip.set_pixel(p, 0) if rand(100) > 20
        end
        strip.show!
        sleep (1 / @hz)
      end
    end
  end

  def slow_hallucination_twinkle(repeat = 5)
    n ||= 1
    repeat.times do
      @strip.each do |ind_strip|
        sleep 1
        n += 2
        ind_strip.set_all_pixels!(color_wheel(n), rand(1..31))
      end
      sleep 1
    end
  end

  def shimmer_well(repeat = 255)
    n ||= 1
    repeat.times do
      sleep 1 / @hz
      n += 1
      @strip.each_with_index do |ind_strip, _idx|
        n += 1
        ind_strip.set_all_pixels!(color_wheel(n), rand(5) + 25)
      end
    end
  end

  def hallucination_well(repeat = 255)
    n ||= 1
    repeat.times do
      sleep 1 / @hz
      n += 2
      @strip.each_with_index do |ind_strip, _idx|
        n += 1
        ind_strip.set_all_pixels!(color_wheel(n), rand(5) + 25)
      end
      n -= 20 if rand(100) < 80
      n -= rand(100) if (n % 100) < 20 # extra hallucinations
    end
  end

  def rainbow_snow
    sleep_time = 1.0 / @hz
    (0..255).each do |c|
      next if rand(100) > 90
      @strip.num_leds.times do |l|
        if rand(10) > 8
          @strip.set_pixel(l, (color_wheel(c)))
        else
          integer = c % 100
          next if rand(integer) > 80
          color = color_wheel(rand(50) + (c % 50) + 100)
          @strip.set_pixel(l, color)
        end
      end
      sleep sleep_time
      @strip.show!
    end
  end

  def rainbow_snow_with_random
    (0..255).each do |c|
      sleep_time = 1 / 40
      next if rand(100) > 90
      @strip.num_leds.times do |l|
        if rand(10) > 8
          @strip.set_pixel(l, (color_wheel(c + rand(5))))
          @strip.set_pixel(l, (color_wheel(c))) if rand(100) > 20
        else
          integer = c % 100
          next if rand(integer) > 80
          color = color_wheel(rand(50) + (c % 50) + 100)
          @strip.set_pixel(l, color)
        end
      end
      sleep sleep_time
      @strip.show!
    end
  end

  def twinkle_twinkle(repeat = 1)
    sleep_time = 1.0 / @hz
    repeat.times do
      (0..255).each do |c|
        next if rand(100) > 90

        @strip.num_leds.times do |l|
          if rand(10) > 8
            @strip.set_pixel(l, (color_wheel(c)))
          else
            integer = c % 100
            next if rand(integer) > 80
            color = color_wheel(rand(50) + (c % 50) + 100)
            @strip.set_pixel(l, color)
          end
        end
        sleep sleep_time
        @strip.show!
      end
    end
  end

  def gradient_with_black_shadow(repeat = 255, color = 1)
    sleep_time = 1.0 / @hz
    n ||= 1
    y ||= 1
    z ||= 1
    y_up ||= true

    repeat.times do
      color += 1 if rand(100) > 80
      n += 1
      if rand(100) > 95
        z += 1
        y_up = !y_up if ((z % 20) == 0)
        y += 1 if y_up
        y -= 1 unless y_up
        y = 1 if y <= 0
      end

      color += rand(3) if rand(100) > 20
      color -= rand(3) if rand(100) < 20

      rand_twinkle = (5 - rand(5).to_i)
      @strip.set_all_pixels(color_wheel(color))
      (1..4).each do |i|
        @strip.set_pixel(n % 82, rand_twinkle)
        @strip.set_pixel(((n + 1) % 82), rand_twinkle)
        @strip.set_pixel(((n + rand(y)) % 82), rand_twinkle)
        @strip.set_pixel(((n + rand(y)) % 82), rand_twinkle)
        @strip.set_pixel(((n + rand(y)) % 82), rand_twinkle)
        @strip.set_pixel(((n + rand(y)) % 82), rand_twinkle)

        pixel = ((n + 41) % 82)
        @strip.set_pixel(pixel, 0)

        pixel = ((n + rand(y) + 41 + i * 82) % 82)
        @strip.set_pixel(pixel, rand_twinkle)
        pixel = ((n + rand(y) + 41 + i * 82) % 82)
        @strip.set_pixel(pixel, rand_twinkle)
        pixel = ((n + rand(y) + 41 + i * 82) % 82)
        @strip.set_pixel(pixel, rand_twinkle)
        pixel = ((n + rand(y) + 41 + i * 82) % 82)
        @strip.set_pixel(pixel, rand_twinkle)
      end
      @strip.show!
      sleep sleep_time
    end
    color
  end

  def pulse(color = color_wheel(rand(255)))
    sleep_time = 1.0 / @hz
    (1..31).each do |brightness|
      @strip.set_all_pixels(color, brightness)
      @strip.show!
      sleep sleep_time
    end
    (1..31).reverse_each do |brightness|
      @strip.set_all_pixels(color, brightness)
      @strip.show!
      sleep sleep_time
    end
  end

  def magic_gradient
    interval = 10
    n = 0
    color = "rgb(#{rand(200)}, #{rand(200)}, #{rand(200)})"
    color_array = make_palette_from_base_color(color, 128, 60)
    sleep_time = 1.0 / @hz
    @strip.clear
    (0..255).each do |c|
      @strip.num_leds.times do |p|
        n = (c + p * interval)
        repeat = rand(8)
        (1..repeat).each do |i|
          @strip.set_pixel(n + i, color_wheel_palette(n, color_array))
        end
      end
      @strip.set_all_pixels(color_wheel_palette(rand(255), color_array)) if rand(100) > 90
      @strip.show!
      sleep sleep_time
      @strip.clear
    end
  end

  def magic_snake(length = 25, interval = 10)
    sleep_time = 1.0 / @hz
    (1..650).each do |offset|
      # blank all pixels out
      @strip.set_pixel(offset, 0)
      # draw the snake
      (0..(length - 1)).each do |snake_pos|
        lit_pixel = (offset + snake_pos) % @strip.num_leds
        @strip.set_pixel(lit_pixel,
          color_wheel(((lit_pixel * interval) & 255) + offset),
        [(31 / (length - snake_pos)), 1].max)
      end
      @strip.show!
      sleep sleep_time
    end
  end
end

# ----- #
# ----- #

def run_magic_rainbow_tunnel(repeat = 15)
  puts "RUNNING MAGIC RAINBOW TUNNEL AT #{Time.now}"
  mirror_and_reverse_strips
  controller_1 = LightController.new(@strip1, 40.0)
  controller_2 = LightController.new(@strip1, 30.0)
  controller_3 = LightController.new(@strip1, 35.0)
  controller_4 = LightController.new(@strip1, 50.0)
  controller_5 = LightController.new(@strip1, 30.0)
  controller_6 = LightController.new(@strip1, 35.0)
  controller_7 = LightController.new(@strip1, 40.0)
  repeat.times do
    choice = rand(1..7)
    controller_1.magic_rainbow_tunnel2 if choice == 1
    controller_2.magic_rainbow_tunnel if choice == 2
    controller_3.magic_rainbow_tunnel2 if choice == 3
    controller_4.magic_rainbow_tunnel if choice == 4
    controller_5.magic_rainbow_tunnel2 if choice == 5
    controller_6.magic_rainbow_tunnel if choice == 6
    controller_7.magic_rainbow_tunnel2 if choice == 7
  end
end

def run_picture_twinkle
  unmirror_strips
  puts "RUNNING PICTURE TWINKLE AT #{Time.now}"
  pixels = []
  image = Dir.glob('/home/pi/LED\ Stuff/ruby/tiles/*').sample
  puts "Picture is #{image}"
  magic = Magick::Image.read(image)[0]
  thumb = magic.scale(25, 25)
  (1..25).each do |row|
    (1..25).each do |column|
      pixel_color = thumb.pixel_color(row, column)
      red = pixel_color.red / 257
      green = pixel_color.green / 257
      blue = pixel_color.blue / 257
      pixels << [red, green, blue]
    end
  end

  controller_1 = LightController.new(@entire_strip, 40.0)
  controller_1.picture_twinkle(pixels)
end

def run_magic_gradient(repeat = 5)
  puts "RUNNING MAGIC GRADIENT AT #{Time.now}"
  unmirror_strips
  controller_1 = LightController.new(@entire_strip, 80.0)
  repeat.times { controller_1.magic_gradient }
end

def run_pulser(repeat = 20)
  puts "RUNNING PULSER AT #{Time.now}"
  mirror_and_reverse_strips
  controller_1 = LightController.new(@strip1, (rand(20) + 20).to_f)
  repeat.times { controller_1.pulse }
end

def run_slow_hallucination_twinkle
  puts "RUNNING SLOW HALLUCINATION TWINKLE AT #{Time.now}"
  mirror_and_reverse_strips
  controller_1 = LightController.new(@strips)
  controller_1.slow_hallucination_twinkle(2)
end

def run_black_shadows(repeat = 2)
  puts "RUNNING BLACK SHADOWS at #{Time.now}"
  color ||= 1
  mirror_and_reverse_strips
  controller_1 = LightController.new(@strip1, 20.0)
  controller_2 = LightController.new(@strip1, 30.0)
  controller_3 = LightController.new(@strip1, 40.0)

  repeat.times do
    color = controller_1.gradient_with_black_shadow(600, color)
    color = controller_2.gradient_with_black_shadow(600, color)
    color = controller_3.gradient_with_black_shadow(600, color) # 600 = one minute
  end
end

def run_palette_painter(repeat = 50)
  puts "RUNNING PALETTE PAINTER AT #{Time.now}"
  unmirror_strips
  controller_1 = LightController.new(@strips, 20.0)
  controller_2 = LightController.new(@strips, 50.0)
  controller_3 = LightController.new(@strips, 30.0)
  controller_4 = LightController.new(@strips, 25.0)
  controller_5 = LightController.new(@strips, 30.0)
  controller_6 = LightController.new(@strips, 35.0)
  controller_7 = LightController.new(@strips, 40.0)

  repeat.times do
    choice = rand(7).to_i
    controller_1.palette_painter_fast if choice == 1
    controller_2.palette_painter_slow if choice == 2
    controller_3.palette_painter_fast if choice == 3
    controller_4.palette_painter_slow if choice == 4
    controller_5.palette_painter_fast if choice == 5
    controller_6.palette_painter_slow if choice == 6
    controller_7.palette_painter_fast if choice == 7
  end
end

def run_magic_snake_painter(repeat = 2)
  puts "RUNNING MAGIC SNAKE PAINTER at #{Time.now}"
  mirror_and_reverse_strips
  controller_1 = LightController.new(@strip1, 20.0)
  controller_2 = LightController.new(@strip1, 50.0)
  controller_3 = LightController.new(@strip1, 30.0)
  controller_4 = LightController.new(@strip1, 25.0)
  controller_5 = LightController.new(@strip1, 30.0)
  controller_6 = LightController.new(@strip1, 35.0)
  controller_7 = LightController.new(@strip1, 40.0)

  repeat.times do
    choice = rand(7).to_i
    controller_1.magic_snake if choice == 1
    controller_2.magic_snake if choice == 2
    controller_3.magic_snake if choice == 3
    controller_4.magic_snake if choice == 4
    controller_5.magic_snake if choice == 5
    controller_6.magic_snake if choice == 6
    controller_7.magic_snake if choice == 7
  end
end

def run_shudder_and_hallucinate(repeat = 4)
  puts "RUNNING SHUDDER AND HALLUCINATE at #{Time.now}"
  unmirror_strips
  controller_1 = LightController.new(@strips, 30.0)
  controller_2 = LightController.new(@strips, 25.0)
  controller_3 = LightController.new(@strips, 35.0)
  controller_4 = LightController.new(@strips, 40.0)
  controller_5 = LightController.new(@strips, 40.0)
  controller_6 = LightController.new(@strips, 35.0)
  controller_7 = LightController.new(@strips, 30.0)

  repeat.times do
    choice = rand(7).to_i
    controller_1.shimmer_well(200) if choice == 1
    controller_2.hallucination_well(200) if choice == 2
    controller_3.shimmer_well(200) if choice == 3
    controller_4.hallucination_well(200) if choice == 4
    controller_5.shimmer_well(200) if choice == 5
    controller_6.hallucination_well(200) if choice == 6
    controller_7.shimmer_well(200) if choice == 7
  end
end

def run_soft_shudder(repeat = 3)
  puts "RUNNING SOFT SHUDDER at #{Time.now}"
  unmirror_strips
  controller_1 = LightController.new(@strips, 20.0)
  controller_2 = LightController.new(@strips, 50.0)
  controller_3 = LightController.new(@strips, 30.0)
  controller_4 = LightController.new(@strips, 25.0)
  controller_5 = LightController.new(@strips, 30.0)
  controller_6 = LightController.new(@strips, 35.0)
  controller_7 = LightController.new(@strips, 40.0)

  repeat.times do
    choice = rand(7).to_i
    controller_1.shimmer_well(200) if choice == 1
    controller_2.shimmer_well(200) if choice == 2
    controller_3.shimmer_well(200) if choice == 3
    controller_4.shimmer_well(200) if choice == 4
    controller_5.shimmer_well(200) if choice == 5
    controller_6.shimmer_well(200) if choice == 6
    controller_7.shimmer_well(200) if choice == 7
  end
end

def run_rainbow_snow(repeat = 1)
  puts "RUNNING RAINBOW SNOW at #{Time.now}"
  mirror_and_reverse_strips
  controller_1 = LightController.new(@strip1, (rand(50) + 1).to_f)
  controller_2 = LightController.new(@strip1, (rand(50) + 1).to_f)
  controller_3 = LightController.new(@strip1, (rand(50) + 1).to_f)
  controller_4 = LightController.new(@strip1, (rand(50) + 1).to_f)
  controller_5 = LightController.new(@strip1, (rand(50) + 1).to_f)
  controller_6 = LightController.new(@strip1, (rand(50) + 1).to_f)
  controller_7 = LightController.new(@strip1, (rand(50) + 1).to_f)

  repeat.times do
    controller_1.rainbow_snow
    controller_2.rainbow_snow_with_random
    controller_3.rainbow_snow
    controller_4.rainbow_snow_with_random
    controller_5.rainbow_snow
    controller_6.rainbow_snow_with_random
    controller_7.rainbow_snow
  end
end

def run_twinkle_twinkle(repeat = 1)
  puts "RUNNING TWINKLE TWINKLE at #{Time.now}"
  mirror_and_reverse_strips
  controller_1 = LightController.new(@strip1, 20.0)
  controller_2 = LightController.new(@strip1, 50.0)
  controller_3 = LightController.new(@strip1, 30.0)
  controller_4 = LightController.new(@strip1, 25.0)
  controller_5 = LightController.new(@strip1, 30.0)
  controller_6 = LightController.new(@strip1, 35.0)
  controller_7 = LightController.new(@strip1, 40.0)

  repeat.times do
    controller_1.twinkle_twinkle(1) # 20 seconds per repeat
    controller_2.twinkle_twinkle(2)
    controller_3.twinkle_twinkle(1)
    controller_4.twinkle_twinkle(2)
    controller_5.twinkle_twinkle(1)
    controller_6.twinkle_twinkle(2)
    controller_7.twinkle_twinkle(1)
  end
end

loop do
  @entire_strip.clear
  choice = rand(1..13)
  run_shudder_and_hallucinate(rand(5) + 10) if choice == 1
  run_black_shadows if choice == 2
  run_magic_snake_painter if choice == 3
  run_twinkle_twinkle if choice == 4
  run_rainbow_snow if choice == 5
  run_slow_hallucination_twinkle if choice == 6
  run_pulser(rand(30)) if choice == 7
  run_palette_painter if choice == 8
  run_magic_gradient if choice == 9
  run_picture_twinkle if choice == 10
  run_soft_shudder if choice == 11
  run_magic_rainbow_tunnel if choice > 11
end
