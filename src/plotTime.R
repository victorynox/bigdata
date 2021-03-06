# ����� �������
#   sold:  ItemID CreatedDate
#   publish:  ItemID ProductID price_real shipping_real add_date

# ��������� ������� ����� ����������
#   ������������ ���� ������ myBDUser = "admin";
#   ������ � ���� ������ myBDPassword = "password";
#   myHost = "RDS Host";
#   myDbname = "MyDB";
#	  route = "/var/www/html/img/";

# �������������� ���������
# ����� ���������
# ��� ����
# ���� ����
# �����

args <- commandArgs(trailingOnly = T); # �������� ��������� �� ��������� ������

{
  FormatDate = "%Y-%m-%d %H:%M";
  myBDUser = args[1];
  myBDPassword = args[2];
  myHost = args[3];
  myDbname = args[4];
  categoryID = ifelse(args[5]!="NA", args[5], "*");
  minPrice = ifelse(args[6]!="NA", args[6], "0");
  maxPrice = ifelse(args[7]!="NA", args[7], "99999");
  brand = ifelse(args[8]!="NA", args[8], "*");
  myRoute = "/home/victorynox/PhpstormProjects/TestR/public/img/";
  myCol = "red";
  mySize = c(960, 960);
  
}# ���������� ����������

getData <- function(name,
                    bdName = myDbname,
                    category = CategoryID,
                    myBrand = brand,
                    minP = minPrice,
                    maxP = maxPrice)
{
  if(name == "publish")
    return(paste("select publish.add_date, publish.ItemID, publish.ProductID, publish.price_real, publish.shipping_real ",
                 " from ", bdName, ".publish", ", ", bdName, ".products ",
                 "where publish.ProductID=products.ProductID and products.brand = '", myBrand, "' and products.ebaycategory_id = ", category, " and publish.price_real>", minP, " and publish.price_real<", maxP,";"  , sep = ""));
  
  if(name == "sold")
    return(paste("select sold.ItemID, sold.CreatedDate ",
                 "from ", bdName, ".sold ",
                 "where sold.ItemID in (select publish.ItemID from ",bdName, ".publish, ", bdName, ".products where publish.ProductID = products.ProductID and products.brand = '", myBrand,"' and products.ebaycategory_id = ", category," and publish.price_real>", minP, " and publish.price_real<", maxP, ");", sep = ""));
  
  
}


{
library(RMySQL)
con <- dbConnect(MySQL(),
                 user = myBDUser,
                 password = myBDPassword,
                 host = myHost,
                 dbname=myDbname);

data.publish <- data.frame(dbGetQuery(conn = con, statement = getData("publish")));
data.sold <-data.frame(dbGetQuery(conn = con, statement = getData("sold")));

q <- dbDisconnect(con);

}# ���������� � ���� ������

checkData <- function(data)
{
  return(nrow(data)>10)
}

if(!checkData(data.sold) | !checkData(data.publish))
{
  print("ERROR");
}

if(checkData(data.sold) & checkData(data.publish))
{
  
{


change.publish <-function(publish=data.publish){
  
  return(publish);
}

change.sold <-function(sold=data.sold){
  
  return(sold);
}

}#��������� ��� ��������� �������� ������


{
data.publish = change.publish();
data.sold = change.sold();
}# ����� �������� ��������� �������� ������



plotTime <- function(publish = data.publish, 
                     sold = data.sold,
                     colHist = myCol,
                     waySave = myRoute,
                     size = mySize){
  
  result = c("a","b","c","d","f","g","q","w","e");
  
  #������ ���� ����������� �������
  publish_date = strptime(publish$add_date, FormatDate);
  
  #������ ���� ����������� �������� �������
  publish_sold_date = strptime(merge(subset(sold, select = c(ItemID, StateOrProvince)), 
                                     subset(publish, select = c(ItemID, add_date)),
                                     by.x = "ItemID", 
                                     by.y = "ItemID")$add_date, 
                               FormatDate);
  
  #������ ���� ������� ������
  sold_date = strptime(sold$CreatedDate, FormatDate);
  
  {
    
    {publish_sold_state = subset(sold, select = c(ItemID, StateOrProvince));
    
    publish_sold_state = transform(publish_sold_state, delTime = 3);
    
    publish_sold_state$delTime[publish_sold_state$StateOrProvince %in% c("WA","OR","CA","NV")]=0;
    
    publish_sold_state$delTime[publish_sold_state$StateOrProvince %in% c("MT","ID","WY","CO","UT","AZ","NM")]=1;
    
    publish_sold_state$delTime[publish_sold_state$StateOrProvince %in% c("ND","MN","SD","IA","WI","IL","NE","KS","MO","OK","AR","TN",
                                                                         "AL","MS","LA","TX","")]=2;
    
    
    publish_sold_state = merge(subset(publish_sold_state, select = c(ItemID, delTime)), 
                               subset(publish, select = c(ItemID, add_date)),
                               by.x = "ItemID", 
                               by.y = "ItemID");
    
    publish_sold_state$add_date =as.POSIXlt(strptime(publish_sold_state$add_date , FormatDate));
    
    publish_sold_state$add_date = publish_sold_state$add_date + 3600*publish_sold_state$delTime; 
    }#������ � ������ ��������� ������
    
    {
    png(file=paste0(waySave, paste0(result[1], ".png")),width = size[1], height = size[2]);
    
    data.sold_time_beg_hist_CHP = hist(as.numeric(format(publish_sold_state$add_date, "%H")),
                                       breaks = seq(-1, 23, by = 1),
                                       freq = FALSE,
                                       col = colHist,
                                       labels = TRUE,
                                       main = "����������� ���������� �������� �� ������� ����� �� �����������(� ������ ��)",
                                       xlab = "����� �����������");
    
    box();
    
    dev.off();
    }#����������� ���������� �������� �� ������� ����� �� �����������(� ������ ��)
    
    
  }#���������� �� ����������
  
  {
  
  index_bud_publish = as.numeric(format(publish_date, "%u")) %in% c(1,2,3,4,5); 
  
  index_bud_publish_sold = as.numeric(format(publish_sold_date, "%u")) %in% c(1,2,3,4,5);
  
  index_bud_sold = as.numeric(format(sold_date, "%u")) %in% c(1,2,3,4,5);
  
  {
    png(file=paste0(waySave, paste0(result[2], ".png")),width = size[1], height = size[2]);
    data.push_time_beg_hist_bd = hist(as.numeric(format(publish_date, "%H"))[index_bud_publish],
                                      breaks = seq(-1, 23, by = 1),
                                      freq = FALSE,
                                      col = colHist,
                                      labels = TRUE,
                                      main = "����������� ���������� ����������� �� ������� �����(������ ���)",
                                      xlab = "����� �����������");
    
    box();
    
    dev.off();
  }#����������� ���������� ����������� �� ������� �����
  
  {
  png(file=paste0(waySave, paste0(result[3], ".png")),width = size[1], height = size[2]);
  
  data.sold_time_beg_hist_bd = hist(as.numeric(format(publish_sold_date, "%H"))[index_bud_publish_sold],
                                    breaks = seq(-1, 23, by = 1),
                                    freq = FALSE,
                                    col = colHist,
                                    labels = TRUE,
                                    main = "����������� ���������� �������� �� ������� ����� �� �����������(������ ���)",
                                    xlab = "����� �����������");
  
  box();
  
  dev.off();
  }#����������� ���������� �������� �� ������� ����� �� �����������
  
  {
  png(file=paste0(waySave, paste0(result[4], ".png")),width = size[1], height = size[2]);
  
  data.sold_time_end_hist_bd = hist(as.numeric(format(sold_date, "%H"))[index_bud_sold],
                                    breaks = seq(-1, 23, by = 1),
                                    freq = FALSE,
                                    col = colHist,
                                    labels = TRUE,
                                    main = "����������� ���������� �������� �� �������(������ ���)",
                                    xlab = "�����");
  
  box();
  
  dev.off();
  }#����������� ���������� �������� �� �������
  
  #������ ����������� ������� ������ ������������ � ������� �����
  data.sold_time_beg_relat_bd = data.sold_time_beg_hist_bd$counts/data.push_time_beg_hist_bd$counts;
  
  {
    png(file=paste0(waySave, paste0(result[5], ".png")),width = size[1], height = size[2]);
    
    data.sold_time_beg_relat_plot_bd = plot(seq(0, 23, by = 1),
                                            data.sold_time_beg_relat_bd,
                                            type = "o",
                                            main = "������ ����������� ������� ������ ������������ � ������� �����(������ ���)",
                                            xlab = "����� �����������",
                                            ylab = "�����������");
    box();
    
    dev.off();
  }#������ ����������� ������� ������ ������������ � ������� �����
  
  }#�� ������ ����
  
  {
  index_hol_publish = as.numeric(format(publish_date, "%u")) %in% c(6,7); 
  
  index_hol_publish_sold = as.numeric(format(publish_sold_date, "%u")) %in% c(6,7);
  
  index_hol_sold = as.numeric(format(sold_date, "%u")) %in% c(6,7);
  
  {
    png(file=paste0(waySave, paste0(result[6], ".png")),width = size[1], height = size[2]);
    data.push_time_beg_hist_hl = hist(as.numeric(format(publish_date, "%H"))[index_hol_publish],
                                      breaks = seq(-1, 23, by = 1),
                                      freq = FALSE,
                                      col = colHist,
                                      labels = TRUE,
                                      main = "����������� ���������� ����������� �� ������� �����(�������� ���)",
                                      xlab = "����� �����������");
    
    box();
    
    dev.off();
  }#����������� ���������� ����������� �� ������� �����
  
  {
  png(file=paste0(waySave, paste0(result[7], ".png")),width = size[1], height = size[2]);
  
  data.sold_time_beg_hist_hl = hist(as.numeric(format(publish_sold_date, "%H"))[index_hol_publish_sold],
                                    breaks = seq(-1, 23, by = 1),
                                    freq = FALSE,
                                    col = colHist,
                                    labels = TRUE,
                                    main = "����������� ���������� �������� �� ������� ����� �� �����������(�������� ���)",
                                    xlab = "����� �����������");
  
  box();
  
  dev.off();
  }#����������� ���������� �������� �� ������� ����� �� �����������
  
  {
  png(file=paste0(waySave, paste0(result[8], ".png")),width = size[1], height = size[2]);
  
  data.sold_time_end_hist_hl = hist(as.numeric(format(sold_date, "%H"))[index_hol_sold],
                                    breaks = seq(-1, 23, by = 1),
                                    freq = FALSE,
                                    col = colHist,
                                    labels = TRUE,
                                    main = "����������� ���������� �������� �� �������(�������� ���)",
                                    xlab = "�����");
  
  box();
  
  dev.off();
  }#����������� ���������� �������� �� �������
  
  #������ ����������� ������� ������ ������������ � ������� �����
  data.sold_time_beg_relat_hl = data.sold_time_beg_hist_hl$counts/data.push_time_beg_hist_hl$counts;
  
  {
    png(file=paste0(waySave, paste0(result[9], ".png")),width = size[1], height = size[2]);
    
    data.sold_time_beg_relat_plot_hl = plot(seq(0, 23, by = 1),
                                            data.sold_time_beg_relat_hl,
                                            type = "o",
                                            main = "������ ����������� ������� ������ ������������ � ������� �����(�������� ���)",
                                            xlab = "����� �����������",
                                            ylab = "�����������");
    box();
    
    dev.off();
  }#������ ����������� ������� ������ ������������ � ������� �����
  
  }#�� �������� ����
  
  return(result);
  
}#����������� �� ������� �����


res <- plotTime()
n <- length(res);

for(i in 1:n)
{
  print(res[i]);
}
}