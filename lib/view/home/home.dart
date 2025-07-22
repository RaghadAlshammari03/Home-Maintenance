// ignore_for_file: unnecessary_null_comparison

import 'package:baligny/controller/provider/profileProvider/profileProvider.dart';
import 'package:baligny/model/userAddressModel.dart';
import 'package:baligny/utils/colors.dart';
import 'package:baligny/utils/textStyles.dart';
import 'package:baligny/view/cart/cart_page.dart';
import 'package:baligny/view/services/Electricity_page.dart';
import 'package:baligny/view/services/air_condition_page.dart';
import 'package:baligny/view/services/plumbing_page.dart';
import 'package:baligny/view/home/viewAddressOverlayScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int activeIndex = 0;

  List<String> imgList = [
    'assets/images/sliderImage1.jpeg',
    'assets/images/sliderImage2.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reviews = [
      {
        'name': 'رغد الشمري',
        'rating': 4.0,
        'text':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua quis nostrud exercitation',
      },
      {
        'name': 'رغد الشمري',
        'rating': 3.0,
        'text':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua quis nostrud exercitation',
      },
      {
        'name': 'رغد الشمري',
        'rating': 5.0,
        'text':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua quis nostrud exercitation',
      },
    ];

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 60,
            backgroundColor: lightOrange,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
            ),
            titleSpacing: 0,
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: greyShade3,
                        radius: 1.5.h,
                        child: FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 1.5.h,
                          color: grey,
                        ),
                      ),

                      Consumer<ProfileProvider>(
                        builder: (context, provider, child) {
                          UserAddressModel? activeAddress;
                            try {
                              activeAddress = provider.addresses.firstWhere((address) => address.isActive);
                            } catch (e) {
                              activeAddress = null;
                            }
                          return TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) =>
                                    const ViewAddressOverlayScreen(),
                              );
                            },
                            label: Row(
                              children: [
                                Text(
                                  activeAddress != null
                                      ? '${activeAddress.addressTitle} - ${activeAddress.roomNo} - ${activeAddress.apartment}'
                                      : 'لا يوجد عنوان افتراضي',
                                  style: AppTextStyles.body16.copyWith(color: white),
                                ),
                                SizedBox(width: 1.w),
                                FaIcon(
                                  FontAwesomeIcons.chevronDown,
                                  size: 1.h,
                                  color: white,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                  },
                  child: FaIcon(
                    FontAwesomeIcons.cartShopping,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            children: [
              SizedBox(height: 1.h),
              // Carousel Slider
              Column(
                children: [
                  CarouselSlider(
                    items: imgList.map((url) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 20.h,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      onPageChanged: (index, reason) {
                        setState(() {
                          activeIndex = index;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 1.h),

                  AnimatedSmoothIndicator(
                    activeIndex: activeIndex,
                    count: imgList.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: darkBlue,
                      dotColor: grey,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 14.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 1.w,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: greyShade3,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.clock,
                              size: 3.h,
                              color: lightOrange,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'متاح 24/7',
                              style: AppTextStyles.body16Bold,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'خدماتنا متاحة\n على مدار الساعة',
                              style: AppTextStyles.body14.copyWith(color: grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 2.w),

                  Expanded(
                    child: SizedBox(
                      height: 14.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 1.w,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: greyShade3,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.solidStar,
                              size: 3.h,
                              color: lightOrange,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'ضمان ذهبي',
                              style: AppTextStyles.body16Bold,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'ضمان لمدة 3 شهور\n على جميع الخدمات',
                              style: AppTextStyles.body14.copyWith(color: grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 2.w),

                  Expanded(
                    child: SizedBox(
                      height: 14.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 1.w,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: greyShade3,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.screwdriverWrench,
                              size: 3.h,
                              color: lightOrange,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'فنيون معتمدون',
                              style: AppTextStyles.body16Bold,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'جميع الفنيين ذو خبرة\n في الصيانة المنزلية',
                              style: AppTextStyles.body14.copyWith(color: grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              Row(
                children: [
                  Container(width: 4, height: 32, color: darkBlue),
                  SizedBox(width: 2.w),
                  Text(
                    'الخدمات المتاحة',
                    style: AppTextStyles.body18Bold.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AirConditionPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: lightOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'التكييف',
                            style: AppTextStyles.body18Bold.copyWith(
                              color: white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 1.h),

                  Expanded(
                    child: SizedBox(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ElectricityPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: lightOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'الكهرباء',
                            style: AppTextStyles.body18Bold.copyWith(
                              color: white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 1.h),

                  Expanded(
                    child: SizedBox(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlumbingPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: lightOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'السباكة',
                            style: AppTextStyles.body18Bold.copyWith(
                              color: white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(width: 4, height: 32, color: darkBlue),
                      SizedBox(width: 2.w),
                      Text(
                        'اراء العملاء',
                        style: AppTextStyles.body18Bold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 1.h),

              // Slider
              CarouselSlider(
                options: CarouselOptions(
                  height: 180,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                ),
                items: reviews.map((review) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Name and Icon
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, size: 30),
                                      SizedBox(width: 8),
                                      Text(
                                        review['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Rating
                                  RatingBarIndicator(
                                    rating: review['rating'],
                                    itemBuilder: (context, _) =>
                                        Icon(Icons.star, color: Colors.amber),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                review['text'],
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
