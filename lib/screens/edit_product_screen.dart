import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // final _titleFoucsNode = FocusNode();
  // final _priceFoucsNode = FocusNode();
  final _imageController = TextEditingController();
  final _imageFoucsNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  // final _titleKey = GlobalKey<FormFieldState>();
  // var _isInit = true;
  var _isLoading = false;

  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  @override
  void initState() {
    super.initState();
    // _imageController.addListener(_updateImageUrl);
    // _titleFoucsNode.addListener(() {
    //   if (!_titleFoucsNode.hasFocus) {
    //     _titleKey.currentState!.validate();
    //   }
    // });
    _imageFoucsNode.addListener(_updateImageUrl);
  }

  @override
  void dispose() {
    super.dispose();
    // _titleFoucsNode.dispose();
    // _priceFoucsNode.dispose();
    _imageFoucsNode.removeListener(_updateImageUrl);
    _imageController.dispose();
    _imageFoucsNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageFoucsNode.hasFocus) setState(() {});
  }

  Future<void> _saveForm() async {
    final bool isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id.isNotEmpty) {
      try {
        await Provider.of<Products>(context, listen: false).updateProduct(
          _editedProduct.id,
          _editedProduct,
        );
        if (!mounted) return;
        Navigator.of(context).pop();
      } finally {}
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);

        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occured'),
            content: const Text('Something went wrong!'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Ok'))
            ],
          ),
        );
      } finally {
        // setState(() {
        //   _isLoading = false;
        // });
      }
    }
    setState(() {
      _isLoading = false;
    });
    // Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    if (productId != null) {
      _editedProduct =
          Provider.of<Products>(context, listen: false).findById(productId);
      _imageController.text = _editedProduct.imageUrl;
    }

    // if(_isInit) {

    // }
    // _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      // key: _titleKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      initialValue: _editedProduct.title,
                      // focusNode: _titleFoucsNode,
                      // onFieldSubmitted: (_) {
                      //   FocusScope.of(context).requestFocus(_priceFoucsNode);
                      // },
                      onSaved: (value) {
                        _editedProduct = _editedProduct.copyWith(title: value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Title must not be empty';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      initialValue: _editedProduct.price <= 0
                          ? ''
                          : _editedProduct.price.toString(),
                      onSaved: (value) {
                        _editedProduct = _editedProduct.copyWith(
                            price: double.parse(value!));
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a Price';
                        } else if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        } else if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than zero.';
                        } else {
                          return null;
                        }
                      },

                      // focusNode: _priceFoucsNode,
                      // onFieldSubmitted: (_) {
                      //   FocusScope.of(context).requestFocus(_titleFoucsNode);
                      // },
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      // textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      initialValue: _editedProduct.description,
                      maxLines: 3,
                      onSaved: (value) {
                        _editedProduct =
                            _editedProduct.copyWith(description: value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a Description';
                        } else if (value.length < 10) {
                          return 'Description should be at least 10 characters';
                        } else {
                          return null;
                        }
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageController.text.isEmpty
                              ? const Center(
                                  child: Text('Enter A URL'),
                                )
                              : Image.network(
                                  _imageController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageController,
                            focusNode: _imageFoucsNode,
                            // onChanged: (value) {
                            //   setState(() {});
                            // },
                            onFieldSubmitted: (_) {
                              setState(() {});
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct =
                                  _editedProduct.copyWith(imageUrl: value);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an image url';
                              } else if (!value.startsWith('http') ||
                                  !value.startsWith('https')) {
                                return 'Please enter a valid url';
                              } else if (!value.endsWith('png') &&
                                  !value.endsWith('jpg')) {
                                return 'Please enter a valid url';
                              } else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
