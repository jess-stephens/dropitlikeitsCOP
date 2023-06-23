
# Setup knitr defaults and folder paths
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, out.width = '100%')

pub_images <- "public_images"

# Set up caption object
caption <- paste0("Source: Testing data from glitr package | Created on: ", Sys.Date())


data_folder <- "C:/Users/jstephens/Documents/Zim/COP23/dropitlikeitsCOP/Graphics"



# Set our data frame to be a gt object
gt_table <- gt(data = df_tst_kp_msd_psnu2)

# preview the table
gt_table

# Set our data frame to be a gt object and declare a groupname_col
# We also hide columns that we are not interested in by using the cols_hide() function

  
  
gt_table <-  df_tst_kp_msd_psnu2 %>%
  # dplyr::select(-prime_partner_name) %>%
  group_by(snu1) %>%
  arrange(desc(fy24_target_psnu_gp)) %>%
  ungroup() %>%
  gt()  %>% 
      tab_header(title = md(str_to_title(x$prime_partner_name[1]))) %>%
      fmt_number(
        columns = c(fy24_target_psnu_gp, fy24_target_psnu_kp),
        decimals = 0,
        use_seps = TRUE
  ) 

# plot_category <- function(x) {
  
gt_table <-df_tst_kp_msd_psnu2 %>%
  dplyr::filter(prime_partner_name=="Centre for Sexual Health and HIV/AIDS Research Zimbabwe") %>%
  # dplyr::select(-prime_partner_name) %>%
  group_by(prime_partner_name) %>%
  arrange((snu1)) %>%
  ungroup() %>%
  gt( groupname_col = "snu1") %>%
  summary_rows(
    groups = TRUE,
    fns = list(
    totals = ~sum(.)),
    use_seps = TRUE,
    decimals = 0
  ) 


  # tab_header(
  #   # title = md(str_to_title(x$prime_partner_name[1])),
  #   subtitle = "PSNU Target Guide"
  # ) 
gt_table


plot_category <- function(x) {
  p <-  df_tst_kp_msd_psnu2 %>%
  dplyr::select(-prime_partner_name) %>%
  arrange((snu1)) %>%
  ungroup() %>%
  gt( groupname_col = "snu1") %>%
  summary_rows(
    groups = TRUE,
    fns = list(
      totals = ~sum(.)),
    use_seps = TRUE,
    decimals = 0
  )  %>% 
    tab_header(title = md(str_to_title(x$prime_partner_name[1])),
               subtitle = "PSNU Target Guide") 
# gt::gtsave(p, file = file.path(paste0("data_folder/", x$prime_partner_name[1], ".png")))
}

df %>%
  dplyr::group_split(prime_partner_name) %>%
  purrr::map(plot_category)

install.packages("webshot2")
library(webshot2)
# %>% 
#     summary_rows(
#       groups = TRUE,
#       columns = c(fy24_target_psnu_gp, fy24_target_psnu_kp),
#       fns = list(
#         totals = ~sum(.)),
#       formatter = fmt_number,
#       use_seps = TRUE,
#       decimals = 0
#     ) 


# +
      # tab_options(table.font.names = "Source Sans Pro")





  # cols_hide(
  #   columns = vars(
  #     annual_results, annual_targets, annual_achievement, deviation, partner_order)
  # ) %>%

  # fmt_percent(
  #   columns = vars(achievement),
  #   decimals = 0,
  # )  %>%



# The HTML decimal references for the black
# up- and down-pointing triangles are: #9650 and #9660;
# use an in-line style to apply color
up_arrow <- "<span style=\"color:#1e87a5\">&#9650;</span>"
down_arrow <- "<span style=\"color:#c43d4d\">&#9660;</span>"

# Show how to use text transform to flag observations
gt_table %>%
  tab_header(title = "Partner Performance") %>%
  tab_options(table.font.names = "Source Sans Pro",
              table_body.hlines.color = "white",
              row_group.border.top.width = px(3),
              row_group.border.top.color = "black",
              row_group.border.bottom.color = "black",
              table_body.border.bottom.width = px(2),
              table_body.border.bottom.color = "black") %>%
  data_color(
    columns = 2:4,
    colors = scales::col_numeric(
      palette = paletteer::paletteer_d(
        palette = "ggsci::blue_material"
      ) %>% as.character(),
      domain = NULL
    )
  )