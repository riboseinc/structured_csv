require 'spec_helper'

RSpec.describe StructuredCsv::Csv2Yaml do
  describe '.get_portion' do
    let(:command) { described_class.method(:get_portion) }
    let(:csv) {
      CSV.parse(
      <<~EOF
      a,b,c
      test_section,1,2,3
      d,e,f
      h,i,j
EOF
      )
    }
    let(:section_name) { 'test_section' }

    it 'returns a specific portion of csv after encountering given section_name' do
      expect(command.call(csv, section_name)).to eql({
        :first_row => 2,
        :last_row  => -1,
        :meta      => { :"1" => nil },
        :rows      => [
          ["d", "e", "f"],
          ["h", "i", "j"],
        ]
      })
    end
  end

  describe '.is_start_of_portion?' do
    let(:section_name) { 'test_section' }
    let(:command) { described_class.method(:is_start_of_portion?) }

    context "if first cell is nil" do
      it "returns false" do
        expect(command.call([nil, section_name], section_name)).to be false
      end
    end

    context "if row is empty" do
      it "returns false" do
        expect(command.call([], section_name)).to be false
      end
    end

    context "if first cell is not nil but is not equal to section name" do
      it "returns false" do
        expect(command.call(['   hi   '], section_name)).to be false
      end
    end

    context "if first cell is equal to section name" do
      it "returns false" do
        expect(command.call([section_name], section_name)).to be true
      end
    end

    context "if first cell is equal to section name with surrounding white space" do
      it "returns false" do
        expect(command.call(["   #{section_name}   "], section_name)).to be true
      end
    end
  end

  describe '.is_row_empty?' do
    let(:command) { described_class.method(:is_row_empty?) }

    context "if row is empty" do
      it "returns true" do
        expect(command.call([])).to be true
      end
    end

    context "if first cell is nil" do
      it "returns true" do
        expect(command.call([nil])).to be true
      end
    end

    context "if only first cell is nil and the rest empty strings" do
      it "returns false" do
        expect(command.call([nil, ''])).to be false
      end
    end

    context "if cells are one of nil/empty string/whitespace" do
      it "returns false" do
        expect(command.call([nil, '', '  ', nil])).to be false
      end
    end

    context "if cells are all nils" do
      it "returns true" do
        expect(command.call([nil, nil, nil])).to be true
      end
    end

    context "if cells are all empty strings" do
      it "returns false" do
        expect(command.call([''])).to be false
      end
    end

    context "if cells are all white spaces" do
      it "returns false" do
        expect(command.call([' ', '  '])).to be false
      end
    end
  end

  describe '.split_header_key_type' do
    let(:command) { described_class.method(:split_header_key_type) }

    it 'splits header type' do
      expect(command.call('aaa[bbb,c[cc]]')).to eql({
        name: 'aaa',
        type: 'bbb,c[cc]',
      })
    end

    it 'returns default type when type is empty' do
      expect(command.call('aaa')).to eql({
        name: 'aaa',
        type: 'string',
      })
    end

    it 'returns empty name when name is empty' do
      expect(command.call('[aaa]')).to eql({
        name: '',
        type: 'aaa',
      })
    end

    it 'returns empty name and default type when all is empty' do
      expect(command.call('')).to eql({
        name: '',
        type: 'string',
      })
    end

    it 'returns empty type when empty type is given' do
      expect(command.call('aaa[]')).to eql({
        name: 'aaa',
        type: '',
      })
    end
  end

  describe '.cast_type' do
    let(:command) { described_class.method(:cast_type) }

    it 'returns nil if given nil value' do
      expect(command.call(nil, '')).to be_nil
    end

    context "given value true" do
      let(:value) { true }

      [
        {
          type_in_string: 'integer',
          expected: 0,
        },
        {
          type_in_string: 'string',
          expected: "true",
        },
        {
          type_in_string: 'boolean',
          expected: nil,
        },
        {
          type_in_string: 'asdf',
          expected: "true",
        },
        {
          type_in_string: 'array{}',
          error: NoMethodError,
        },
      ].each do |h|
          if !h[:error].nil?
            it "raises #{h[:error]} if type_in_string is #{h[:type_in_string]}" do
              expect{ command.call(value, h[:type_in_string]) }.to raise_error h[:error]
            end
          else
            it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
              expect(command.call(value, h[:type_in_string])).to eql h[:expected]
            end
          end
        end
    end

    context "given value false" do
      let(:value) { false }

      [
        {
          type_in_string: 'integer',
          expected: 0,
        },
        {
          type_in_string: 'string',
          expected: "false",
        },
        {
          type_in_string: 'boolean',
          expected: nil,
        },
        {
          type_in_string: 'asdf',
          expected: "false",
        },
        {
          type_in_string: 'array{}',
          error: NoMethodError,
        },
      ].each do |h|
          if !h[:error].nil?
            it "raises #{h[:error]} if type_in_string is #{h[:type_in_string]}" do
              expect{ command.call(value, h[:type_in_string]) }.to raise_error h[:error]
            end
          else
            it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
              expect(command.call(value, h[:type_in_string])).to eql h[:expected]
            end
          end
        end
    end

    context 'given value " true "' do
      let(:value) { " true " }

      [
        {
          type_in_string: 'integer',
          expected: 0,
        },
        {
          type_in_string: 'string',
          expected: "true",
        },
        {
          type_in_string: 'boolean',
          expected: nil,
        },
        {
          type_in_string: 'asdf',
          expected: " true ",
        },
        {
          type_in_string: 'array{}',
          expected: [" true "],
        },
      ].each do |h|
          it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
            expect(command.call(value, h[:type_in_string])).to eql h[:expected]
          end
        end
    end

    context 'given value " false "' do
      let(:value) { " false " }

      [
        {
          type_in_string: 'integer',
          expected: 0,
        },
        {
          type_in_string: 'string',
          expected: "false",
        },
        {
          type_in_string: 'boolean',
          expected: nil,
        },
        {
          type_in_string: 'asdf',
          expected: " false ",
        },
        {
          type_in_string: 'array{}',
          expected: [" false "],
        },
      ].each do |h|
          it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
            expect(command.call(value, h[:type_in_string])).to eql h[:expected]
          end
        end
    end

    context 'given value "true"' do
      let(:value) { "true" }

      [
        {
          type_in_string: 'integer',
          expected: 0,
        },
        {
          type_in_string: 'string',
          expected: "true",
        },
        {
          type_in_string: 'boolean',
          expected: true,
        },
        {
          type_in_string: 'asdf',
          expected: "true",
        },
        {
          type_in_string: 'array{}',
          expected: ["true"],
        },
      ].each do |h|
          it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
            expect(command.call(value, h[:type_in_string])).to eql h[:expected]
          end
        end
    end

    context 'given value "false"' do
      let(:value) { "false" }

      [
        {
          type_in_string: 'integer',
          expected: 0,
        },
        {
          type_in_string: 'string',
          expected: "false",
        },
        {
          type_in_string: 'boolean',
          expected: false,
        },
        {
          type_in_string: 'asdf',
          expected: "false",
        },
        {
          type_in_string: 'array{}',
          expected: ["false"],
        },
      ].each do |h|
          it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
            expect(command.call(value, h[:type_in_string])).to eql h[:expected]
          end
        end
    end

    context 'given value 1' do
      let(:value) { 1 }

      [
        {
          type_in_string: 'integer',
          expected: 1,
        },
        {
          type_in_string: 'string',
          expected: "1",
        },
        {
          type_in_string: 'boolean',
          expected: nil,
        },
        {
          type_in_string: 'asdf',
          expected: "1",
        },
        {
          type_in_string: 'array{}',
          error: NoMethodError,
        },
      ].each do |h|
          if !h[:error].nil?
            it "raises #{h[:error]} if type_in_string is #{h[:type_in_string]}" do
              expect{ command.call(value, h[:type_in_string]) }.to raise_error h[:error]
            end
          else
            it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
              expect(command.call(value, h[:type_in_string])).to eql h[:expected]
            end
          end
        end
    end

    context 'given value " 005 "' do
      let(:value) { " 005 " }

      [
        {
          type_in_string: 'integer',
          expected: 5,
        },
        {
          type_in_string: 'string',
          expected: "005",
        },
        {
          type_in_string: 'boolean',
          expected: nil,
        },
        {
          type_in_string: 'asdf',
          expected: " 005 ",
        },
        {
          type_in_string: 'array{}',
          expected: [" 005 "],
        },
      ].each do |h|
          it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
            expect(command.call(value, h[:type_in_string])).to eql h[:expected]
          end
        end
    end

    context 'given value " 005 ; 006 ; true ; false ;true;false"' do
      let(:value) { " 005 ; 006 ; true ; false ;true;false" }

      [
        {
          type_in_string: 'integer',
          expected: 5,
        },
        {
          type_in_string: 'string',
          expected: "005 ; 006 ; true ; false ;true;false",
        },
        {
          type_in_string: 'boolean',
          expected: nil,
        },
        {
          type_in_string: 'asdf',
          expected: " 005 ; 006 ; true ; false ;true;false",
        },
        {
          type_in_string: 'array{}',
          expected: [" 005 ", " 006 ", " true ", " false ", "true", "false"],
        },
        {
          type_in_string: 'array{boolean}',
          expected: [nil, nil, nil, nil, true, false],
        },
        {
          type_in_string: 'array{integer}',
          expected: [5, 6, 0, 0, 0, 0],
        },
        {
          type_in_string: 'array{string}',
          expected: ["005", "006", "true", "false", "true", "false"],
        },
        {
          type_in_string: 'array{string}',
          expected: ["005", "006", "true", "false", "true", "false"],
        },
        {
          type_in_string: 'array{array}',
          expected: [" 005 ", " 006 ", " true ", " false ", "true", "false"],
        },
        {
          type_in_string: 'array{array{}}',
          expected: [[" 005 "], [" 006 "], [" true "], [" false "], ["true"], ["false"]],
        },
        {
          type_in_string: 'array{array{string}}',
          expected: [["005"], ["006"], ["true"], ["false"], ["true"], ["false"]],
        },
      ].each do |h|
          it "returns #{h[:expected]} if type_in_string is #{h[:type_in_string]}" do
            expect(command.call(value, h[:type_in_string])).to eql h[:expected]
          end
        end
    end

  end

  describe '.parse_metadata' do
    let(:command) { described_class.method(:parse_metadata) }
    [
      {
        value: [],
        expected: {},
      },
      {
        value: [[]],
        expected: {},
      },
      {
        value: [['test', 'a', 'b']],
        expected: {'test' => 'a'},
      },
      {
        value: [['test']],
        expected: {'test' => nil},
      },
      {
        value: [['test', 'a', 'b'], ['test', 'c', 'd']],
        expected: {'test' => 'c'},
      },
      {
        value: [['test', '1', 'boolean'], ['test', 'c', 'd']],
        expected: {'test' => 'c'},
      },
      {
        value: [['test[boolean]', '1']],
        expected: {'test' => nil},
      },
      {
        value: [['test[integer]', '1']],
        expected: {'test' => 1},
      },
      {
        value: [['test[array{ integer }]', '1']],
        expected: {'test' => ['1']},
      },
      {
        value: [['test[array{integer}]', '1;a;a;1;0;true;false']],
        expected: {'test' => [1,0,0,1,0,0,0]},
      },
      {
        value: [
          ['a[array{integer}]', '1;a;a;1;0;true;false'],
          ['a[array{array{integer}}]', '1;a;a;1;0;true;false'],
          ['a[array{integer}]', '1;a;a;1;0;true;false'],
        ],
        expected: {'a' => [1,0,0,1,0,0,0]},
      },
      {
        value: [
          ['a[array{integer}]', '1;a;a;1;0;true;false'],
          ['b[array{array{integer}}]', '1;a;a;1;0;true;false'],
          ['c[array{string}]', '1;a;a;1;0;true;false'],
          ['d[array{boolean}]', '1;a;a;1;0;true;false'],
        ],
        expected: {
          'a' => [1,0,0,1,0,0,0],
          "b" => [[1], [0], [0], [1], [0], [0], [0]],
          "c" => ["1", "a", "a", "1", "0", "true", "false"],
          "d" => [nil, nil, nil, nil, nil, true, false],
        },
      },
      {
        value: [[], [], [[]]],
        error: NoMethodError,
      },
    ].each do |h|
        if !h[:error].nil?
          it "raises #{h[:error]} if given #{h[:value]}" do
            expect{ command.call(h[:value]) }.to raise_error h[:error]
          end
        else
          it "returns #{h[:expected]} if given #{h[:value]}" do
            expect(command.call(h[:value])).to eql h[:expected]
          end
        end
      end
  end

  describe '.parse_data' do
    let(:command) { described_class.method(:parse_data) }

    [
      {
        args: [[], {}],
        expected: {},
      },
      {
        args: [[], { name: '', type: '', key: ''}],
        expected: {'' => nil},
      },
      {
        args: [[['a,b,c,d,e']], { name: '', type: '', key: ''}],
        expected: {'' => nil},
      },
      {
        args: [[%w[a b c d e]], { name: '', type: '', key: ''}],
        expected: {'' => nil},
      },
      # TODO: need more tests here
    ].each do |h|
        if !h[:error].nil?
          it "raises #{h[:error]} if given #{h[:args]}" do
            expect{ command.call(*h[:args]) }.to raise_error h[:error]
          end
        else
          it "returns #{h[:expected]} if given #{h[:args]}" do
            expect(command.call(*h[:args])).to eql h[:expected]
          end
        end
      end
  end

  describe '.convert' do
    let(:command) { described_class.method(:convert) }
    let(:tmp_dir) { create_tmp_dir }
    let(:csv_file) {
      name = File.join(tmp_dir, 'temp.csv')
      File.write(name, csv_content)
      name
    }
    let(:csv_content) { '' }

    context 'when argument is not a file' do
      it 'throws error' do
        expect{ command.call('') }.to raise_error
      end
    end

    context 'when given directory has csv files' do
      before do
        csv_file
      end

      after do
        FileUtils.rm(csv_file)
      end

      it 'does not throw error' do
        expect{ command.call(csv_file) }.to_not raise_error RuntimeError
      end

      [
        {
          arg: '',
          expected: {
            'metadata' => {},
            'data' => {},
          },
        },
        {
          arg: <<~EOS,
            METADATA,,,,,,,,,,,,,,
            title.en,SERVICE RESTRICTIONS (Recapitulatory list of service restrictions in force relating to telecommunications operation),,,,,,,,,,,,,
            title.fr,RESTRICTIONS DE SERVICE (Liste récapitulative des restrictions de service en vigueur relatives à l’exploitation des télécommunications),,,,,,,,,,,,,
            title.es,RESTRICCIONES DE SERVICIO (Lista recapitulativa de las restricciones de servicio en vigor relativas a la explotación de las telecomunicaciones),,,,,,,,,,,,,
            locale.geographic_area.en,Country/Geographical area,,,,,,,,,,,,,
            locale.geographic_area.fr,Países/Zonas geográficas,,,,,,,,,,,,,
            locale.geographic_area.es,Pays/Zones géographiques,,,,,,,,,,,,,
            ,,,,,,,,,,,,,,
            ,,,,,,,,,,,,,,
            DATA,,,,,,,,,,,,,,
            geographic_area.fr,geographic_area.en,geographic_area.es,restrictions.telex_not_provided[boolean],restrictions.telegram_not_provided[boolean],restrictions.no_collect_calls.mobile[boolean],restrictions.no_collect_calls.payphone[boolean],restrictions.no_collect_calls.audiotex[boolean],restrictions.no_collect_calls.virtual[boolean],restrictions.no_collect_calls.incoming[boolean],restrictions.no_collect_calls.outgoing[boolean],restrictions.no_messenger_dispatch[boolean],notes.en,notes.es,notes.fr
          EOS
          expected: {
            'metadata' => {
              "locale" => {"geographic_area"=> {
                "en" => "Country/Geographical area",
                "es" => "Pays/Zones géographiques",
                "fr" => "Países/Zonas geográficas"},
              },
              "title" => {
                "en" => "SERVICE RESTRICTIONS (Recapitulatory list of service restrictions in force relating to telecommunications operation)",
                "es" => "RESTRICCIONES DE SERVICIO (Lista recapitulativa de las restricciones de servicio en vigor relativas a la explotación de las telecomunicaciones)",
                "fr" => "RESTRICTIONS DE SERVICE (Liste récapitulative des restrictions de service en vigueur relatives à l’exploitation des télécommunications)",
              },
            },
            'data' => {},
          },
        },
        {
          arg: <<~EOS,
            METADATA,,,,,,,,,,,,,,
            title.en,SERVICE RESTRICTIONS (Recapitulatory list of service restrictions in force relating to telecommunications operation),,,,,,,,,,,,,
            title.fr,RESTRICTIONS DE SERVICE (Liste récapitulative des restrictions de service en vigueur relatives à l’exploitation des télécommunications),,,,,,,,,,,,,
            title.es,RESTRICCIONES DE SERVICIO (Lista recapitulativa de las restricciones de servicio en vigor relativas a la explotación de las telecomunicaciones),,,,,,,,,,,,,
            locale.geographic_area.en,Country/Geographical area,,,,,,,,,,,,,
            locale.geographic_area.fr,Países/Zonas geográficas,,,,,,,,,,,,,
            locale.geographic_area.es,Pays/Zones géographiques,,,,,,,,,,,,,
            ,,,,,,,,,,,,,,
            ,,,,,,,,,,,,,,
            DATA,,,,,,,,,,,,,,
            geographic_area.fr,geographic_area.en,geographic_area.es,restrictions.telex_not_provided[boolean],restrictions.telegram_not_provided[boolean],restrictions.no_collect_calls.mobile[boolean],restrictions.no_collect_calls.payphone[boolean],restrictions.no_collect_calls.audiotex[boolean],restrictions.no_collect_calls.virtual[boolean],restrictions.no_collect_calls.incoming[boolean],restrictions.no_collect_calls.outgoing[boolean],restrictions.no_messenger_dispatch[boolean],notes.en,notes.es,notes.fr
            Andorre,Andorra,Andorra,TRUE,,,,,,,,,The telex service is no longer provided.,El servicio télex está suprimido ,Le service télex n'est plus assuré.
          EOS
          expected: {
            'metadata' => {
              "locale" => {"geographic_area"=> {
                "en" => "Country/Geographical area",
                "es" => "Pays/Zones géographiques",
                "fr" => "Países/Zonas geográficas"},
              },
              "title" => {
                "en" => "SERVICE RESTRICTIONS (Recapitulatory list of service restrictions in force relating to telecommunications operation)",
                "es" => "RESTRICCIONES DE SERVICIO (Lista recapitulativa de las restricciones de servicio en vigor relativas a la explotación de las telecomunicaciones)",
                "fr" => "RESTRICTIONS DE SERVICE (Liste récapitulative des restrictions de service en vigueur relatives à l’exploitation des télécommunications)",
              },
            },
            'data' => {
              "Andorre" => {
                "geographic_area" => {
                  "en" => "Andorra",
                  "es" => "Andorra",
                  "fr" => "Andorre",
                },
                "notes" => {
                  "en" => "The telex service is no longer provided.",
                  "es" => "El servicio télex está suprimido",
                  "fr" => "Le service télex n'est plus assuré.",
                },
              },
            },
          },
        },
      ].each do |h|
        context do
          let(:csv_content) {
            h[:arg]
          }
          if !h[:error].nil?
            it "raises #{h[:error]} if content is #{h[:arg]}" do
              expect{ command.call(csv_file) }.to raise_error h[:error]
            end
          else
            it "returns #{h[:expected]} if content is #{h[:arg]}" do
              expect(command.call(csv_file)).to eql h[:expected]
            end
          end
        end
      end
    end

  end

  describe '.normalize_namespaces' do
    let(:command) { described_class.method(:normalize_namespaces) }

    [
      {
        arg: {},
        expected: {},
      },
      {
        arg: { 'hello' => 'asdf ' },
        expected: { 'hello' => 'asdf ' },
      },
      {
        arg: { '1.1.1.1' => 'asdf ' },
        expected: { '1' => { '1' => { '1' => { '1' => 'asdf '}}}},
      },
      {
        arg: { ':1.:1.:1.:1' => 'asdf ' },
        expected: { ':1' => { ':1' => { ':1' => { ':1' => 'asdf '}}}},
      },
      {
        arg: { 'true.....' => 'asdf ' },
        expected: { 'true' => 'asdf '},
      },
      {
        arg: { 'true..... ' => 'asdf ' },
        expected: { 'true' => {""=>{""=>{""=>{""=>{" "=>"asdf "}}}}}},
      },
      {
        arg: { 'true.....false' => 'asdf ' },
        expected: { 'true' => {""=>{""=>{""=>{""=>{"false"=>"asdf "}}}}}},
      },
      {
        arg: { 'hello.me' => 'asdf ' },
        expected: { 'hello' => { 'me' => 'asdf ' }},
      },
    ].each do |h|
        if !h[:error].nil?
          it "raises #{h[:error]} if given #{h[:arg]}" do
            expect{ command.call(h[:arg]) }.to raise_error h[:error]
          end
        else
          it "returns #{h[:expected]} if given #{h[:arg]}" do
            expect(command.call(h[:arg])).to eql h[:expected]
          end
        end
      end
  end

end
