# Action: Test Ansible with Molecule

Github Action for testing ansible with Molecule.

## Inputs

### command

**Default** 'test'

What command to pass to [molecule](https://molecule.readthedocs.io/en/latest/),
for example `lint` or `syntax`.

### working_directory

**Default** '${{ github.repository }}'

Path to another directory in the repository,
where molecule command will be issued from.

### scenario

**Default** 'default'

The molecule scenario to run.

## Example Usage

```yaml
- name: Test Ansible with Molecule
  uses: arillso/action.molecule@0.0.1
  with:
    command: test
    working_directory: ${{ github.repository }}
    scenario: default
```

## License

<!-- markdownlint-disable -->

This project is under the MIT License. See the [LICENSE](licence) file for the full license text.

<!-- markdownlint-enable -->

## Copyright

(c) 2020, Arillso
