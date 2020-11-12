change version in zpp/version.py
git tag -sm "Zpp release ${VERSION}" "${VERSION}"
rm -R dist
python3 -B setup.py sdist
python3 -m twine upload dist/*
