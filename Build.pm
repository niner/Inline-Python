# This generic Build.pm is for installation on old zef versions only.
# It can go away once users have upgraded zef.
class Build {
    method build($workdir) {
        my $meta-text = $workdir.IO.child('META6.json').slurp;
        my $meta = Rakudo::Internals::JSON.from-json($meta-text);
        if $meta<builder>:exists {
            (require ::("Distribution::Builder::$meta<builder>")).new(:$meta).build;
        }
    }
}
