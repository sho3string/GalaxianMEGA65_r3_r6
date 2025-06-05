----------------------------------------------------------------------------------
-- MiSTer2MEGA65 Framework
--
-- Wrapper for the MiSTer core that runs exclusively in the core's clock domanin
--
-- MiSTer2MEGA65 done by sy2002 and MJoergen in 2022 and licensed under GPL v3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.video_modes_pkg.all;

entity main is
   generic (
      G_VDNUM                 : natural                     -- amount of virtual drives
   );
   port (
      clk_main_i              : in  std_logic;
      reset_soft_i            : in  std_logic;
      reset_hard_i            : in  std_logic;
      pause_i                 : in  std_logic;


      -- MiSTer core main clock speed:
      -- Make sure you pass very exact numbers here, because they are used for avoiding clock drift at derived clocks
      clk_main_speed_i        : in  natural;

      -- Video output
      video_ce_o              : out std_logic;
      video_ce_ovl_o          : out std_logic;
      video_red_o             : out std_logic_vector(2 downto 0);
      video_green_o           : out std_logic_vector(2 downto 0);
      video_blue_o            : out std_logic_vector(2 downto 0);
      video_vs_o              : out std_logic;
      video_hs_o              : out std_logic;
      video_hblank_o          : out std_logic;
      video_vblank_o          : out std_logic;

      -- Audio output (Signed PCM)
      audio_left_o            : out signed(15 downto 0);
      audio_right_o           : out signed(15 downto 0);

      -- M2M Keyboard interface
      kb_key_num_i            : in  integer range 0 to 79;    -- cycles through all MEGA65 keys
      kb_key_pressed_n_i      : in  std_logic;                -- low active: debounced feedback: is kb_key_num_i pressed right now?

      -- MEGA65 joysticks and paddles/mouse/potentiometers
      joy_1_up_n_i            : in  std_logic;
      joy_1_down_n_i          : in  std_logic;
      joy_1_left_n_i          : in  std_logic;
      joy_1_right_n_i         : in  std_logic;
      joy_1_fire_n_i          : in  std_logic;

      joy_2_up_n_i            : in  std_logic;
      joy_2_down_n_i          : in  std_logic;
      joy_2_left_n_i          : in  std_logic;
      joy_2_right_n_i         : in  std_logic;
      joy_2_fire_n_i          : in  std_logic;

      pot1_x_i                : in  std_logic_vector(7 downto 0);
      pot1_y_i                : in  std_logic_vector(7 downto 0);
      pot2_x_i                : in  std_logic_vector(7 downto 0);
      pot2_y_i                : in  std_logic_vector(7 downto 0);
      
      dsw_a_i                 : in  std_logic_vector(7 downto 0);              
      dsw_b_i                 : in  std_logic_vector(7 downto 0);
      dsw_c_i                 : in  std_logic_vector(7 downto 0);
      
      dn_clk_i                : in  std_logic;
      dn_addr_i               : in  std_logic_vector(15 downto 0);
      dn_data_i               : in  std_logic_vector(7 downto 0);
      dn_wr_i                 : in  std_logic;
      
      qnice_dev_id_o          : out std_logic_vector(15 downto 0);
      osm_control_i           : in  std_logic_vector(255 downto 0)
   );
end entity main;

architecture synthesis of main is

-- @TODO: Remove these demo core signals
signal keyboard_n                : std_logic_vector(79 downto 0);
signal reset                     : std_logic := reset_hard_i or reset_soft_i;
signal clk_6m                    : std_logic;

signal sw                        : std_logic_vector(7 downto 0);
signal sw0                       : std_logic_vector(7 downto 0);
signal sw1                       : std_logic_vector(7 downto 0);

signal audio                     : std_logic_vector(10 downto 0);
signal audio_a, audio_b, audio_c : std_logic_vector(7 downto 0);
signal audio_signed              : signed(10 downto 0);
signal audio_padded              : signed(15 downto 0);
signal flip_screen               : std_logic;
signal pause_cpu                 : std_logic := '0';

-- highscore system
signal hs_address       : std_logic_vector(10 downto 0);
signal hs_data_in       : std_logic_vector(7 downto 0);
signal hs_data_out      : std_logic_vector(7 downto 0);
signal hs_write_enable  : std_logic;
signal hs_pause         : std_logic;
signal options          : std_logic_vector(1 downto 0);
signal hd_configured    : std_logic;
signal m_test           : std_logic;

-- Game player inputs
constant m65_1           : integer := 56; --Player 1 Start
constant m65_2           : integer := 59; --Player 2 Start
constant m65_5           : integer := 16; --Insert coin 1
constant m65_6           : integer := 19; --Insert coin 2

-- Offer some keyboard controls in addition to Joy 1 Controls
constant m65_a             : integer := 10; --Player left
constant m65_d             : integer := 18; --Player right
constant m65_up_crsr       : integer := 73; --Player fire



-- change these values based on menu
constant C_MENU_OSMPAUSE     : natural := 2;
constant C_MENU_OSMDIM       : natural := 3;
constant C_MENU_FLIP         : natural := 9;

-- Pause, credit button & test mode
constant m65_p               : integer := 41; --Pause button

begin

   --sw  <= m_test & '1' & '1' & m_fire & m_right & m_left & '0' & m_coin;
   sw0 <= "00000001"; -- Galaxian
   sw1 <= "00000001"; -- Galaxian
   
   audio <= (others => '0') when pause_cpu = '1' else
         std_logic_vector(
           unsigned('0' & audio_b & "00") + 
           unsigned("000" & audio_a) + 
           unsigned("00" & audio_c & '0')
         );
         
   --audio_left_o(10) <= not audio(10);
   --audio_left_o(9 downto 0) <= signed(audio(9 downto 0));
   --audio_right_o(10) <= not audio(10);
   --audio_right_o(9 downto 0) <= signed(audio(9 downto 0));
  
   audio_signed <= signed(unsigned(audio) - 1024);
   audio_padded <= resize(audio_signed, 16);  -- sign-extend to 16 bits
   audio_left_o  <= audio_padded;
   audio_right_o <= audio_padded;
    
   options(0) <= osm_control_i(C_MENU_OSMPAUSE);
   options(1) <= osm_control_i(C_MENU_OSMDIM);
   flip_screen <= osm_control_i(C_MENU_FLIP);

   process (clk_main_i) -- 12mhz / 2
   begin
      if rising_edge(clk_main_i) then
        clk_6m <= not clk_6m; 
      end if;
   end process;

   i_galaxian : entity work.galaxian
   port map (
        w_clk_12m      => clk_main_i,
        w_clk_6m       => clk_6m,
        i_reset        => reset,
        w_sw0_di       => sw0,
        w_sw1_di       => sw1,
        w_dip_di       => sw,
        w_r            => video_red_o,
        w_g            => video_green_o,
	    w_b            => video_blue_o,
	    w_h_sync       => video_hs_o,
	    w_v_sync       => video_vs_o,
	    hblank         => video_hblank_o,
	    vblank         => video_vblank_o,
	    dn_clk         => dn_clk_i,  -- on falling edge
	    dn_addr        => dn_addr_i(15 downto 0),
	    dn_data        => dn_data_i,
	    dn_wr          => dn_wr_i,
	    hs_address     => hs_address,
        hs_data_out    => hs_data_out,
        hs_data_in     => hs_data_in,
        hs_write       => hs_write_enable,
        pause_cpu_n    => not pause_cpu,
        mod_mooncr     => '0',
        mod_devilfsh   => '0',
        mod_pisces     => '0',
        mod_kingbal    => '0',
        mod_orbitron   => '0',
        mod_moonqsr    => '0',
        mod_porter     => '0',
        mod_uniwars    => '0',
        flip_vertical  => flip_screen,
        w_sdat_a       => audio_a,
	    w_sdat_b       => audio_b,
	    w_sdat_c       => audio_c
   );
   
   i_pause : entity work.pause
     generic map (
     
        RW  => 3,
        GW  => 3,
        BW  => 3,
        CLKSPD => 24
        
     )         
     port map (
     
         clk_sys        => clk_main_i,
         reset          => reset,
         user_button    => keyboard_n(m65_p),
         pause_request  => hs_pause,
         options        => options,  -- not status(11 downto 10), - TODO, hookup to OSD.
         OSD_STATUS     => '0',       -- disabled for now - TODO, to OSD
         r              => video_red_o,
         g              => video_green_o,
         b              => video_blue_o,
         pause_cpu      => pause_cpu
         --rgb_out        TODO
         
      );
      
      
   i_keyboard : entity work.keyboard
      port map (
         clk_main_i           => clk_main_i,

         -- Interface to the MEGA65 keyboard
         key_num_i            => kb_key_num_i,
         key_pressed_n_i      => kb_key_pressed_n_i,

         -- @TODO: Create the kind of keyboard output that your core needs
         -- "example_n_o" is a low active register and used by the demo core:
         --    bit 0: Space
         --    bit 1: Return
         --    bit 2: Run/Stop
         example_n_o          => keyboard_n
      ); -- i_keyboard

end architecture synthesis;

